#!/usr/bin/env python3
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


CHATTER = Path(__file__).with_name("chatter")


def run_chatter(*args, input_text=None, check=True):
    return subprocess.run(
        [str(CHATTER), *args],
        input=input_text,
        text=True,
        capture_output=True,
        check=check,
    )


class ChatterLoopTest(unittest.TestCase):
    def test_loop_returns_non_self_messages_and_persists_cursor(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            run_chatter("post", "--root", str(root), "thread", "claude-code", "first")

            result = run_chatter("loop", "--root", str(root), "thread", "codex")
            payload = json.loads(result.stdout)

            self.assertEqual("messages", payload["status"])
            self.assertEqual(["first"], [m["content"] for m in payload["messages"]])
            self.assertEqual("0001-claude-code.md", payload["last_seen"])

            result = run_chatter(
                "loop",
                "--root",
                str(root),
                "thread",
                "codex",
                "--timeout",
                "0",
                "--silences",
                "1",
                check=False,
            )
            payload = json.loads(result.stdout)

            self.assertEqual(1, result.returncode)
            self.assertEqual("silent", payload["status"])
            self.assertEqual("0001-claude-code.md", payload["last_seen"])

    def test_loop_skips_self_messages_but_advances_cursor(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            run_chatter("post", "--root", str(root), "thread", "codex", "mine")

            result = run_chatter(
                "loop",
                "--root",
                str(root),
                "thread",
                "codex",
                "--timeout",
                "0",
                "--silences",
                "1",
                check=False,
            )
            payload = json.loads(result.stdout)

            self.assertEqual(1, result.returncode)
            self.assertEqual("silent", payload["status"])
            self.assertEqual("0001-codex.md", payload["last_seen"])

    def test_loop_since_flag_overrides_saved_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            run_chatter("post", "--root", str(root), "thread", "claude-code", "first")

            run_chatter("loop", "--root", str(root), "thread", "codex")
            saved = (root / "thread" / ".chatter-state" / "codex.json").read_text()
            self.assertIn("0001-claude-code.md", saved)

            run_chatter("post", "--root", str(root), "thread", "claude-code", "second")

            result = run_chatter(
                "loop",
                "--root",
                str(root),
                "thread",
                "codex",
                "--since",
                "0000-aaa.md",
            )
            payload = json.loads(result.stdout)

            self.assertEqual("messages", payload["status"])
            self.assertEqual(
                ["first", "second"],
                [m["content"] for m in payload["messages"]],
            )

    def test_loop_skips_malformed_md_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            run_chatter("post", "--root", str(root), "thread", "claude-code", "good")

            (root / "thread" / "0002-junk.md").write_text("not valid frontmatter\n")

            result = run_chatter("loop", "--root", str(root), "thread", "codex")
            payload = json.loads(result.stdout)

            self.assertEqual("messages", payload["status"])
            self.assertEqual(["good"], [m["content"] for m in payload["messages"]])
            self.assertIn("skipping malformed", result.stderr)


if __name__ == "__main__":
    unittest.main()
