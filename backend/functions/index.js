/* eslint-disable */

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { setGlobalOptions } = require("firebase-functions/v2");
const Groq = require("groq-sdk");

setGlobalOptions({ maxInstances: 10 });

const groqApiKey = defineSecret("GROQ_API_KEY");

exports.nabadAssistant = onCall(
    {
        region: "us-central1",
        secrets: [groqApiKey],
        timeoutSeconds: 60,
    },
    async (request) => {
        const message = request.data.message;

        if (!message || typeof message !== "string") {
            throw new HttpsError("invalid-argument", "Message is required.");
        }

        try {
            const groq = new Groq({
                apiKey: groqApiKey.value(),
            });

            const completion = await groq.chat.completions.create({
                model: "llama-3.1-8b-instant",
                messages: [
                    {
                        role: "system",
                        content:
                            "You are Nabad, a helpful medical assistant app for Lebanese users. " +
                            "Answer health-related questions in the same language the user writes in. " +
                            "If the user writes in Arabic, respond in Arabic. " +
                            "If the user writes in English, respond in English. " +
                            "Keep answers simple, clear, and helpful. " +
                            "If the question is not health-related, politely redirect to health topics. " +
                            "Never diagnose. " +
                            "Always recommend seeing a doctor for serious symptoms or emergencies. " +
                            "For emergencies in Lebanon, mention calling 140 Lebanese Red Cross.",
                    },
                    {
                        role: "user",
                        content: message,
                    },
                ],
                temperature: 0.4,
                max_tokens: 300,
            });

            let reply = "Sorry, I could not understand that.";

            if (
                completion &&
                completion.choices &&
                completion.choices.length > 0 &&
                completion.choices[0].message &&
                completion.choices[0].message.content
            ) {
                reply = completion.choices[0].message.content;
            }

            return { reply: reply };
        } catch (error) {
            console.error("GROQ ERROR:", error);

            throw new HttpsError(
                "internal",
                "The assistant is temporarily unavailable. Please try again shortly."
            );
        }
    }
);
