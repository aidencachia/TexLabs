# TexLabs MVP delivery plan

This plan expands the four phases in the [first-release specification](spec.md#11-delivery-sequence). The phases are implementation milestones, not separate releases. The MVP ships after Phase 4; the [specification](spec.md) defines its scope and [acceptance tests](spec.md#10-release-acceptance-tests).

The page is the editing surface, the ordinary LaTeX project is the source of truth, and the compiled PDF is the authority on final layout. Prove that the editor can preserve source and keep typing stable before adding more authoring features.

## Phase 1 — Prove the editing model

**Deliver:** A Rust/GPUI prototype that opens a two-file project and supports editing prose in an included chapter. Derive editable ranges from the working source, anchor the caret and selection to the text, and apply delayed layout only when it still matches the current revision and editing has paused. Save only the edited source range. Use a fixture with a page break, comments, and unsupported syntax.

**Exit gate:** A no-op save leaves the fixture byte-for-byte unchanged. A visual typo correction changes only the intended text in the chapter file. While typing across a page boundary or composing text with an input method, a delayed result must not move the active passage, disrupt composition, or drop input. After idle reconciliation, the caret still points to the same logical text position. Use the focused fixture to prove the behavior in A02–A04 before expanding the editor.

## Phase 2 — Build the document editor

**Deliver:**

- Add project creation and navigation, all seven template choices, root selection, and multi-file opening. Retain file identity and relative paths; surface missing files and include cycles without blocking unrelated edits.
- Add visual prose, headings, formatting, and lists. Mark unsupported or ambiguously mapped regions and offer source editing rather than guessing where to write.
- Add full-file source mode with a hideable side preview, shared working text and undo, and safe saves. Start external-change handling here: reload clean changes and surface conflicts before writing.
- Integrate a first local compilation path for the side preview. Build the selected root from a snapshot of working edits without forcing a save. Require trust for unfamiliar projects before compiling, leave shell escape disabled by default, and distinguish stale or failed results from current output.

**Exit gate:** Open a generated Paper and an existing multi-file project. Edit an included chapter in either mode, hide and restore the side preview, and undo the edit once from the other mode. The preview builds the root with the unsaved chapter edit; on-disk files stay unchanged until save. Unsupported source survives an unrelated edit, external edits are not silently overwritten, and editing and saving still work without TeX (A02–A05, A09–A11, and A13 as applicable).

## Phase 3 — Complete technical authoring

**Deliver:** Add inline and displayed equations with in-place LaTeX editing; figure insertion and a width, caption, label, and placement inspector; symbolic references to sections, figures, and equations; and the bibliography menu to add or link sources, insert citations, and place bibliography output. Reuse supported existing bibliography setups rather than replacing them, including the FYP template’s `biblatex` configuration. Apply structural actions as targeted edits and group changes across files into one undo step per action.

**Exit gate:** In a Paper created without a `.bib` file, insert an equation and a captioned figure, reference the figure, add and cite an article, and build a PDF with the citation and bibliography. Insert another figure earlier and verify the reference still points to its original target and displays the new number. Repeat the citation flow with an existing bibliography without rewriting unrelated entries. Verify incomplete equation input survives saving and existing equation labels remain intact (A06–A08).

## Phase 4 — Qualify the release

**Deliver:** Finish PDF export, build cancellation and diagnostics, crash recovery, and keyboard and accessibility coverage. Verify outside-app compilation, safe handling of external edits and failed exports, and the full local build flow for all seven templates, including the FYP bibliography and glossary. Compare settled editing pages with compiled PDFs and measure typing latency on a documented reference Mac and multi-chapter fixture.

**Release gate:** Run A01–A14 on the supported macOS and TeX setup. Record the minimum macOS version, tested TeX distribution, engine and template dependencies, bibliography backend, renderer, and known visual deviations. Land no release with data loss, stale output presented as current, missing content, or incorrect resolved references. A shared project must still open and compile outside TexLabs without app-private files.

## Not part of the MVP

Keep other platforms, a template marketplace or designer, PDF import, general-purpose visual editing for arbitrary LaTeX, online reference lookup, bundled TeX, cloud storage, and real-time collaboration out of these phases. Unsupported LaTeX must still be preserved and accessible in source mode.
