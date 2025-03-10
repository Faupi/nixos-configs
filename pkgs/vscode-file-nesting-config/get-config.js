// Mostly taken from extension/src/fetch.ts, in JS because I'm lazy
// Fetches the -entire- configuration, so patterns are nested

const fs = require("node:fs");

export async function main() {
  const md = fs.readFileSync("./README.md", "utf8");
  const content = (md.match(/```jsonc([\s\S]*?)```/) || [])[1] || "";

  const json = `{${content
    .trim()
    .split(/\n/g)
    .filter((line) => !line.trim().startsWith("//"))
    .join("\n")
    .slice(0, -1)}}`;

  console.log(json);
}
