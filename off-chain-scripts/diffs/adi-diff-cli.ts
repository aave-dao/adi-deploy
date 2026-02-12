import {readFileSync, writeFileSync, mkdirSync} from 'fs';
import {dirname} from 'path';
import {aDISnapshotSchema} from './snapshot-types';
import {adiDiffReports} from './adi-diff-reports';

const args = process.argv.slice(2);

const outputFlagIndex = args.indexOf('-o');
if (args.length < 2 || outputFlagIndex === -1 || outputFlagIndex + 1 >= args.length) {
  console.error('Usage: adi-diff-cli <before.json> <after.json> -o <output.md>');
  process.exit(1);
}

const beforePath = args[0];
const afterPath = args[1];
const outputPath = args[outputFlagIndex + 1];

const pre = aDISnapshotSchema.parse(JSON.parse(readFileSync(beforePath, 'utf-8')));
const post = aDISnapshotSchema.parse(JSON.parse(readFileSync(afterPath, 'utf-8')));

(async () => {
  const content = await adiDiffReports(pre, post);
  mkdirSync(dirname(outputPath), {recursive: true});
  writeFileSync(outputPath, content);
})();
