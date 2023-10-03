import { registerSW } from "virtual:pwa-register";
import "./app.css";
import App from "./App.svelte";

const app = new App({
  target: document.getElementById("app"),
});

registerSW({ immediate: true });

export default app;
