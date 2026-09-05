"""Regression checks for file-target resolution during topic moves."""

import subprocess
import sys
from pathlib import Path

SCRIPT = Path(__file__).with_name("topic_tools.py")


def note(root, path, text=""):
    target = root / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding="utf-8")
    return target


def linkcheck(project, vault=None):
    command = [sys.executable, str(SCRIPT), "linkcheck", "--project", str(project)]
    if vault is not None:
        command.extend(["--vault", str(vault)])
    return subprocess.run(command, text=True, capture_output=True)


def test_moved_note_does_not_resolve_its_old_qualified_path(tmp_path):
    note(tmp_path, "New/Topic.md")
    note(tmp_path, "Task.md", "[[Old/Topic]] [[New/Topic]] [[Topic]]")

    result = linkcheck(tmp_path)

    assert result.returncode == 0, result.stderr
    assert "old/topic" in result.stdout
    assert "1 unresolved file target(s)" in result.stdout


def test_graduated_note_resolves_from_project_against_vault(tmp_path):
    project = tmp_path / "Projects/Example"
    note(tmp_path, "Development/Topic.md")
    note(project, "Tasks/Task.md", "[[Topic]] [[Development/Topic]]")

    result = linkcheck(project, tmp_path)

    assert result.returncode == 0, result.stderr
    assert "0 unresolved file target(s)" in result.stdout


def test_preserves_paths_with_extensions_fragments_and_display_text(tmp_path):
    project = tmp_path / "Projects/Example"
    note(project, "Topics/Topic.md")
    note(project, "Tasks/Task.md", "\n".join([
        "[[../Topics/Topic]]",
        "[[Topics/Topic]]",
        "[[Projects/Example/Topics/Topic.md#Heading|Label]]",
        r"| [[Topics/Topic\|Label]] |",
        "[[#Local heading]]",
        "[[Missing/Topic.md#Heading|Label]]",
    ]))

    result = linkcheck(project, tmp_path)

    assert result.returncode == 0, result.stderr
    assert "missing/topic.md" in result.stdout
    assert "1 unresolved file target(s)" in result.stdout


def test_vault_scan_checks_incoming_links_and_moved_note_links(tmp_path):
    note(tmp_path, "Development/Topic.md", "[[Missing outgoing]]")
    note(tmp_path, "Projects/Other/Task.md", "[[Projects/Example/Topics/Topic]]")

    result = linkcheck(tmp_path, tmp_path)

    assert result.returncode == 0, result.stderr
    assert "missing outgoing" in result.stdout
    assert "projects/example/topics/topic" in result.stdout
    assert "2 unresolved file target(s)" in result.stdout


def test_external_attachments_resolve_as_files(tmp_path):
    project = tmp_path / "Projects/Example"
    note(tmp_path, "Attachments/diagram.png")
    note(project, "Task.md", "![[Attachments/diagram.png]] [[diagram.png]]")

    result = linkcheck(project, tmp_path)

    assert result.returncode == 0, result.stderr
    assert "0 unresolved file target(s)" in result.stdout


def test_missing_resolution_root_fails_instead_of_reporting_clean(tmp_path):
    note(tmp_path, "Task.md")

    result = linkcheck(tmp_path, tmp_path / "missing")

    assert result.returncode != 0
    assert "not a directory" in result.stderr
