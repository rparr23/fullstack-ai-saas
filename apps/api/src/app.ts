import crypto from "node:crypto";
import cors from "cors";
import express from "express";
import helmet from "helmet";
import { analysisRequestSchema } from "@signaldesk/contracts";
import { analyzeFeedback } from "./analysis.js";

const attempts = new Map<string, { count: number; resetAt: number }>();

export function createApp() {
  const app = express();
  app.disable("x-powered-by");
  app.use(helmet());
  app.use(cors({ origin: (process.env.WEB_ORIGIN ?? "http://localhost:5173").split(","), credentials: true }));
  app.use(express.json({ limit: "256kb" }));
  app.use((req, res, next) => { res.setHeader("x-request-id", req.header("x-request-id") ?? crypto.randomUUID()); next(); });
  app.get("/health", (_req, res) => res.json({ status: "ok" }));
  app.get("/ready", (_req, res) => res.json({ status: "ready", provider: process.env.AI_PROVIDER ?? "mock" }));
  app.post("/v1/analyses", (req, res) => {
    const actor = req.header("authorization") ?? req.ip ?? "anonymous";
    const now = Date.now();
    const bucket = attempts.get(actor);
    const current = !bucket || bucket.resetAt < now ? { count: 0, resetAt: now + 60_000 } : bucket;
    current.count += 1; attempts.set(actor, current);
    res.setHeader("x-ratelimit-limit", "10"); res.setHeader("x-ratelimit-remaining", String(Math.max(0, 10 - current.count)));
    if (current.count > 10) return res.status(429).json({ error: { code: "rate_limited", message: "Try again in a minute." } });
    const parsed = analysisRequestSchema.safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ error: { code: "invalid_request", message: "Check the submitted feedback.", details: parsed.error.flatten() } });
    return res.status(201).json(analyzeFeedback(parsed.data.feedback));
  });
  app.use((_req, res) => res.status(404).json({ error: { code: "not_found", message: "Route not found." } }));
  return app;
}
