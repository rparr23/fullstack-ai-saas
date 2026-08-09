import request from "supertest";
import { describe, expect, it } from "vitest";
import { createApp } from "./app.js";

describe("API", () => {
  it("reports health", async () => expect((await request(createApp()).get("/health")).body.status).toBe("ok"));
  it("rejects invalid analyses", async () => expect((await request(createApp()).post("/v1/analyses").send({})).status).toBe(400));
});
