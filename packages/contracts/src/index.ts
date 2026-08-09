import { z } from "zod";

export const feedbackItemSchema = z.object({
  id: z.string(),
  source: z.enum(["interview", "support", "survey", "review"]),
  body: z.string().min(8).max(8_000),
  customer: z.string().max(120).optional(),
  createdAt: z.string().datetime(),
});

export const analysisRequestSchema = z.object({
  projectId: z.string().min(1),
  feedback: z.array(feedbackItemSchema).min(2).max(100),
  idempotencyKey: z.string().min(8).max(100),
});

export const themeSchema = z.object({
  id: z.string(),
  title: z.string(),
  summary: z.string(),
  urgency: z.enum(["critical", "high", "medium", "low"]),
  trend: z.enum(["rising", "steady", "falling"]),
  recommendation: z.string(),
  evidenceIds: z.array(z.string()).min(1),
});

export const analysisSchema = z.object({
  id: z.string(),
  status: z.enum(["queued", "running", "succeeded", "failed"]),
  headline: z.string(),
  summary: z.string(),
  themes: z.array(themeSchema),
  usage: z.object({ items: z.number().int(), units: z.number().int(), limit: z.number().int() }),
  createdAt: z.string().datetime(),
});

export type FeedbackItem = z.infer<typeof feedbackItemSchema>;
export type AnalysisRequest = z.infer<typeof analysisRequestSchema>;
export type Analysis = z.infer<typeof analysisSchema>;
