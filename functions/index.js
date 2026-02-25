/**
 * HappyFood AI Backend (Firebase Functions v2 + OpenAI + .env)
 */

import { onRequest } from "firebase-functions/v2/https";
import OpenAI from "openai";
import cors from "cors";
import dotenv from "dotenv";

// 1️⃣ Загружаем переменные из .env
dotenv.config();
const OPENAI_API_KEY = process.env.AI_KEY;

// 2️⃣ Конфигурация
const REGION = "europe-west1"; // Регион (низкая задержка)
const corsHandler = cors({ origin: true }); // Разрешаем все домены

// 3️⃣ Rate Limiting (в памяти)
const rateLimitMap = new Map();
const RATELIMIT_WINDOW_MS = 60 * 1000; // 1 минута
const MAX_REQUESTS_PER_IP = 10;

/**
 * Chat Endpoint
 * Method: POST
 * URL: https://europe-west1-<project-id>.cloudfunctions.net/chatWithAI
 */
export const chatWithAI = onRequest(
    {
        region: REGION,
        cors: true,
        maxInstances: 10,
    },
    async (req, res) => {
        corsHandler(req, res, async () => {
            // 🔹 Только POST
            if (req.method !== "POST") {
                res.status(405).send("Method Not Allowed");
                return;
            }

            // 🔹 Проверка входных данных
            const { message, profile } = req.body;
            if (!message || typeof message !== "string" || message.length > 500) {
                res.status(400).json({ error: "Invalid message. Must be a string < 500 chars." });
                return;
            }

            // 🔹 Rate limiting
            const ip = req.headers["x-forwarded-for"] || req.socket.remoteAddress || "unknown";
            const now = Date.now();
            const userRate = rateLimitMap.get(ip) || { count: 0, startTime: now };

            if (now - userRate.startTime > RATELIMIT_WINDOW_MS) {
                userRate.count = 1;
                userRate.startTime = now;
            } else {
                userRate.count++;
            }
            rateLimitMap.set(ip, userRate);

            if (userRate.count > MAX_REQUESTS_PER_IP) {
                console.warn(`Rate limit exceeded for IP: ${ip}`);
                res.status(429).json({ error: "Too many requests. Please wait." });
                return;
            }

            // 🔹 AI Logic
            try {
                const openai = new OpenAI({
                    apiKey: OPENAI_API_KEY, // Берем из .env
                });

                let systemPrompt =
                    "You are a professional, calm, and supportive nutrition assistant for the HappyFood app. " +
                    "Your goal is to help users maintain a healthy diet. " +
                    "Keep answers concise (max 3-4 sentences). " +
                    "Refuse to answer non-nutrition questions. " +
                    "Do NOT give medical advice.";

                if (profile) {
                    systemPrompt += `\n\nUser Profile:\n`;
                    if (profile.weight) systemPrompt += `- Weight: ${profile.weight}kg\n`;
                    if (profile.goal) systemPrompt += `- Goal: ${profile.goal}\n`;
                    if (profile.calories) systemPrompt += `- Target: ${profile.calories} kcal/day\n`;
                    if (profile.allergies && Array.isArray(profile.allergies)) {
                        systemPrompt += `- Allergies: ${profile.allergies.join(", ")}\n`;
                    }
                }

                console.log(`Processing request for IP: ${ip} (hidden content)`);

                const completion = await openai.chat.completions.create({
                    model: "gpt-4o-mini",
                    messages: [
                        { role: "system", content: systemPrompt },
                        { role: "user", content: message },
                    ],
                    max_tokens: 300,
                    temperature: 0.7,
                });

                const reply = completion.choices[0].message.content;

                res.status(200).json({
                    reply,
                    caloriesMentioned: /calor|kcal/i.test(reply),
                    timestamp: new Date().toISOString(),
                });
            } catch (error) {
                console.error("OpenAI API Fail:", error.message);
                res.status(500).json({ error: "AI service temporarily unavailable." });
            }
        });
    }
);
