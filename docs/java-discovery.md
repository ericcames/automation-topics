# Java Discovery — Script → Playbook

A worked example of converting an imperative Bash discovery script into an
idempotent, inventory-aware Ansible playbook. Useful as a talking point for the
classic "we have a pile of shell scripts — why automate them?" conversation.

- **Playbook:** [`java-discovery-playbook.yml`](java-discovery-playbook.yml)

## Executive Summary

The original Bash script is a **JVM discovery / inventory tool**. On a single
host it answers one question: *"Which Java runtimes are installed here, and what
are they?"* Concretely it:

1. Prints the machine's hostname.
2. Walks the **entire filesystem** (`find / -type f -iname java`) for any file
   named `java`, case-insensitively, silencing permission errors.
3. Skips anything that is not executable.
4. For each real `java` binary it found, prints:
   - the full path to the binary,
   - the output of `java -version` (vendor, version, JVM build), and
   - the `java.runtime.version` and `java.vendor` runtime properties pulled from
     `java -XshowSettings:properties`, gracefully noting when an older JVM does
     not support that flag.

In short: it surfaces **every Java install on a box — including stray, bundled,
or shadow JDKs** that a package manager may not know about — which is exactly the
kind of data you need for license audits, Log4Shell-style CVE sweeps, and upgrade
planning.

## Why Convert It to Ansible?

The script does its job on **one** machine, interactively, with no record of the
result. The same logic as a playbook gains the things that matter at fleet scale:

| Shell script | Ansible playbook |
|---|---|
| One host, run by hand over SSH | Any number of hosts in parallel from inventory |
| Output scrolls past in a terminal | Structured result; optional per-host text report on disk |
| No audit trail | Runs through AAP with logging, RBAC, and scheduling |
| Re-run = re-read the screen | Idempotent read-only scan; safe to schedule nightly |
| Logic trapped in Bash | Declarative tasks any teammate can read and extend |

This is the standard "lift a script into the platform" pattern: the *intent*
stays identical, but it becomes repeatable, governed, and observable.

## How the Conversion Maps

| Bash | Ansible |
|---|---|
| `hostname` | `gather_facts` → `inventory_hostname` |
| `sudo find / -iname java` | `ansible.builtin.find` with `use_regex: '(?i)^java$'`, `recurse: true`, run with `become: true` |
| `[[ ! -x "$JAVA" ]] && continue` | `selectattr('mode', 'search', exec_mode_regex)` keeps only executables |
| `2>/dev/null` | `find` silently skips unreadable directories |
| `"$JAVA" -version` | `ansible.builtin.command` (`failed_when: false`, `changed_when: false`) |
| `-XshowSettings:properties` + `grep` | second `command` task + `regex_findall` for `java.runtime.version` / `java.vendor` |
| `else echo "...does not support..."` | `{% if props %}…{% else %}…{% endif %}` in the report template |

Both `java -version` and `-XshowSettings` write to **stderr**, so the playbook
reads `stderr` (falling back to `stdout`) when building the report. The
executable check relies on the fact that an octal permission digit with the
execute bit set is always odd (1, 3, 5, 7), anchored to the final three mode
characters so setuid/sticky bits can't cause a false positive.

## Running It

Local box only:

```bash
ansible-playbook -i localhost, -c local docs/java-discovery-playbook.yml
```

Across an inventory, also writing a `java-discovery-<host>.txt` report on each
target:

```bash
ansible-playbook -i inventory docs/java-discovery-playbook.yml \
  -e write_report_file=true -e report_dir=/var/tmp
```

Scope the scan (far faster than walking `/`):

```bash
ansible-playbook -i inventory docs/java-discovery-playbook.yml \
  -e java_search_root=/usr/lib/jvm
```

> **Performance note:** like the original, the default walks the whole
> filesystem, which is thorough but slow on hosts with large or networked
> mounts. Narrow `java_search_root` (e.g. `/usr`, `/opt`, `/usr/lib/jvm`)
> whenever you know where JVMs live.

## Original Script

```bash
#!/bin/bash

HOST=$(hostname)

echo "Hostname: $HOST"
echo "Searching for Java installations..."
echo

# Case-insensitive search for any file named java
sudo find / -type f -iname java 2>/dev/null | while read JAVA; do

    # Ensure it's executable
    if [[ ! -x "$JAVA" ]]; then
        continue
    fi

    echo "----------------------------------------"
    echo "Java binary location: $JAVA"

    # Always show basic version info
    echo "---- java -version ----"
    "$JAVA" -version 2>&1
    echo

    # Try extended properties (not all Java versions support this)
    echo "---- java runtime properties ----"
    PROPS=$("$JAVA" -XshowSettings:properties -version 2>&1)

    if [[ $? -eq 0 ]]; then
        echo "$PROPS" | grep -E "^ *java.runtime.version =|^ *java.vendor ="
    else
        echo "This Java does not support -XshowSettings:properties"
    fi

    echo "----------------------------------------"
    echo
    echo
done
```
