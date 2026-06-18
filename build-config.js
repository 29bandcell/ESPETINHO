const fs = require("fs");

function env(name, fallback = "") {
  return process.env[name] || fallback;
}

const config = {
  SUPABASE_URL: env("SUPABASE_URL"),
  SUPABASE_ANON_KEY: env("SUPABASE_ANON_KEY"),
  SUPABASE_SCHEMA: env("SUPABASE_SCHEMA", "espetinho_gordinho"),
  OWNER_PASSWORD: env("OWNER_PASSWORD", "Espetinho@2026"),
  PIX_KEY: env("PIX_KEY", "63.512.299/0001-83"),
  PIX_NAME: env("PIX_NAME", "Francisco Dionísio"),
};

const content = `window.ESPETINHO_CONFIG = ${JSON.stringify(config, null, 2)};\n`;

fs.writeFileSync("outputs/config.js", content, "utf8");
console.log("Generated outputs/config.js from Netlify environment variables.");
