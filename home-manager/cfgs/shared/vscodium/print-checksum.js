// Script for getting vscode file checksums, it was honestly easier this way

import { readFileSync } from "fs";
import { createHash } from "crypto";
const filename = process.argv[2];
const contents = readFileSync(filename);
const checksum = createHash("sha256")
  .update(contents)
  .digest("base64")
  .replace(/=+$/, "");
console.log(checksum);
