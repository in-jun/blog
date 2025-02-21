---
title: "Learn to Use the 'tar' Command Quickly"
date: 2025-02-18T21:17:41+09:00
tags: ["tar", "compression", "linux", "command"]
description: "This article explains the core options of the Linux tar command with practical examples."
draft: false
---

tar is the most widely used compression/decompression tool in Linux. The name tar is short for 'Tape Archive', and it was originally created for tape backups. However, it is now the most common tool used to bundle and compress files.

## Essential Basic Options You Should Know

tar commands are broadly divided into action specification options and action modifiers. All tar commands use a combination of these two types of options.

### Action Specification Options

-   c: Create a new archive (file)
-   x: Extract an archive
-   t: List the contents of an archive
-   r: Append files to an archive
-   u: Update files in an archive

### Action Modifier Options

-   f: Specify the file name (almost always used)
-   v: Print the progress of processing
-   z: Use gzip compression (.tar.gz)
-   j: Use bzip2 compression (.tar.bz2)
-   J: Use xz compression (.tar.xz)

## Frequently Used Options

### Compression

```bash
# Create a basic tar file
tar cf archive.tar files/

# Compress with gzip (most commonly used)
tar czf archive.tar.gz files/

# Compress with bzip2 (higher compression ratio)
tar cjf archive.tar.bz2 files/
```

### Decompression

```bash
# Extract a tar file
tar xf archive.tar

# Decompress a gzip compressed file
tar xzf archive.tar.gz

# Decompress a bzip2 compressed file
tar xjf archive.tar.bz2
```

### Listing Files

```bash
# View the contents of a tar file
tar tf archive.tar

# View in detail
tar tvf archive.tar
```

## Options That Are Really Useful to Know

### Path Related

-   -C : Run from a different directory
-   -P : Keep absolute paths
-   --strip-components=N : Remove the top N directories when extracting

### File Selection

-   --exclude : Exclude specific files/directories
-   --exclude-from : Read a list of files to exclude from a file
-   --wildcards : Use wildcard patterns

### Attribute Preservation

-   -p : Preserve file permissions
-   --same-owner : Preserve ownership information
-   --numeric-owner : Preserve UID/GID

## Conclusion

tar is used for a variety of purposes in addition to file compression. In system backups, the -p option is important because it preserves file permissions and ownership information. When distributing software, xz compression is mainly used because it has a high compression ratio.

In the case of web applications with complex directory structures, it is important to exclude unnecessary files such as logs and caches when backing up. Such files can be excluded with the --exclude option.
