import "dotenv/config";
import { createApp } from "./app.js";
const port = Number(process.env.API_PORT ?? 8787);
createApp().listen(port, () => console.log(JSON.stringify({ level: "info", event: "api_started", port })));
