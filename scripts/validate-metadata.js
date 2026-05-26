const fs = require('fs');
const path = require('path');

const skillsDir = path.join(__dirname, '../catalog/skills');
let hasErrors = false;

if (!fs.existsSync(skillsDir)) {
  console.error(`❌ Error: Catalog directory not found at ${skillsDir}`);
  process.exit(1);
}

// Read all subdirectories in catalog/skills
const skillDirs = fs.readdirSync(skillsDir).filter(f => fs.statSync(path.join(skillsDir, f)).isDirectory());

console.log(`🔍 Scanning catalog skills for metadata validation...\n`);

for (const dir of skillDirs) {
  const skillMdPath = path.join(skillsDir, dir, 'SKILL.md');
  if (!fs.existsSync(skillMdPath)) {
    console.error(`❌ Error in ${dir}: Missing SKILL.md file.`);
    hasErrors = true;
    continue;
  }

  const content = fs.readFileSync(skillMdPath, 'utf8');
  
  // Extract frontmatter block between the first two --- delimiters
  const lines = content.split(/\r?\n/);
  if (lines[0] !== '---') {
    console.error(`❌ Error in ${dir}/SKILL.md: File must start with "---" to open YAML frontmatter.`);
    hasErrors = true;
    continue;
  }

  let frontmatterEndIndex = -1;
  for (let i = 1; i < lines.length; i++) {
    if (lines[i] === '---') {
      frontmatterEndIndex = i;
      break;
    }
  }

  if (frontmatterEndIndex === -1) {
    console.error(`❌ Error in ${dir}/SKILL.md: Could not find closing "---" for YAML frontmatter.`);
    hasErrors = true;
    continue;
  }

  const frontmatterLines = lines.slice(1, frontmatterEndIndex);
  const metadata = {};
  let currentParent = metadata;
  let inMetadataBlock = false;

  for (let i = 0; i < frontmatterLines.length; i++) {
    const origLine = frontmatterLines[i];
    const trimmed = origLine.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;

    // Check indent level
    const indent = origLine.search(/\S/);

    if (inMetadataBlock && indent <= 1) {
      inMetadataBlock = false;
      currentParent = metadata;
    }

    if (trimmed === 'metadata:') {
      inMetadataBlock = true;
      metadata.metadata = {};
      currentParent = metadata.metadata;
      continue;
    }

    if (trimmed.includes(':')) {
      const separatorIdx = trimmed.indexOf(':');
      const key = trimmed.substring(0, separatorIdx).trim();
      let value = trimmed.substring(separatorIdx + 1).trim();

      // Strip optional wrapping quotes (single or double)
      if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }

      currentParent[key] = value;
    } else {
      console.error(`⚠️ Warning in ${dir}/SKILL.md: Non-standard YAML line inside frontmatter: "${trimmed}"`);
    }
  }

  // Validation checks
  const requiredRoot = ['name', 'description', 'license'];
  let fileHasErrors = false;

  for (const field of requiredRoot) {
    if (!metadata[field]) {
      console.error(`❌ Error in ${dir}/SKILL.md: Missing required field "${field}"`);
      fileHasErrors = true;
      hasErrors = true;
    }
  }

  if (!metadata.metadata) {
    console.error(`❌ Error in ${dir}/SKILL.md: Missing "metadata" block`);
    fileHasErrors = true;
    hasErrors = true;
  } else {
    const requiredMetadata = ['author', 'version'];
    for (const field of requiredMetadata) {
      if (!metadata.metadata[field]) {
        console.error(`❌ Error in ${dir}/SKILL.md: Missing required subfield "metadata.${field}"`);
        fileHasErrors = true;
        hasErrors = true;
      }
    }
  }

  if (metadata.name && metadata.name !== dir) {
    console.error(`❌ Error in ${dir}/SKILL.md: Skill "name" ("${metadata.name}") must match the folder name ("${dir}")`);
    fileHasErrors = true;
    hasErrors = true;
  }

  if (!fileHasErrors) {
    console.log(`✅ ${dir}/SKILL.md: Valid metadata (Name: "${metadata.name}", Version: "${metadata.metadata ? metadata.metadata.version : 'N/A'}")`);
  }
}

console.log('');
if (hasErrors) {
  console.error('❌ Validation failed! Please fix the errors listed above before pushing.');
  process.exit(1);
} else {
  console.log('🎉 All catalog skills validated successfully!');
}
