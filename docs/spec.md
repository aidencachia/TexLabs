# Visual LaTeX Editor for macOS

- **Status:** First-release product and engineering specification
- **Platform:** macOS desktop
- **Application framework:** Rust and GPUI
- **Document format:** Ordinary LaTeX projects (`.tex`, `.bib`, and assets)
- **Export format:** PDF, produced by a separately installed local LaTeX toolchain

## 1. Product definition

The application lets an author write directly on a typeset-looking page without routinely editing LaTeX code. Clicking a paragraph places a text caret. Clicking an equation reveals its LaTeX. Selecting a figure exposes placement and sizing options. The author edits document content, not pixels on a PDF.

**The page is the editing surface. The LaTeX project is the source of truth. The compiled PDF is the authority on final layout.**

The editor must work both for someone starting an assignment without knowing LaTeX and for a colleague who wants to edit the resulting project in another editor. It must not require conversion into a proprietary document format.

## 2. Release scope

| Included in the first release | Not required in the first release |
|---|---|
| macOS application built with GPUI | Windows, Linux, web, or mobile clients |
| Assignment, Paper, Thesis, and Letter templates, plus University Article, University Report, and University Final Year Project | A template marketplace or visual template designer |
| Opening and editing existing multi-file LaTeX projects | Recovering an editable project from a PDF |
| Visual editing of prose, headings, basic formatting, lists, equations, and figures | Visual editing of every LaTeX package, macro, table, or diagram |
| Cross-references, citations, and a bibliography menu | Online publication lookup or a general-purpose reference manager |
| Full-file source editing with a hideable side preview | A permanent split-screen interface |
| PDF preview and export using a local LaTeX installation | Bundling a TeX distribution |
| Sequential collaboration through ordinary project files | Real-time collaborative editing or cloud storage |

“Not visually supported” does **not** mean “discard on import.” Existing source outside the visual feature set must remain accessible and preservable.

## 3. Core authoring workflow

An author starting a paper should be able to:

1. Choose **File → New → Paper**, select a destination, and begin typing on the page.
2. Add a heading and a displayed equation. Enter the equation as LaTeX, then leave it to see the formatted result.
3. Insert an image, add a caption, and refer to it from a paragraph without typing its figure number.
4. Choose **Bibliography → Add Source…**, enter an article, and cite it at the caret.
5. Inspect the compiled preview and export a PDF containing the equation, figure reference, citation, and bibliography.
6. Send the project folder to a colleague. The colleague can edit and compile it without the application. Reopening the returned folder must retain the colleague’s changes.

The same workflow must work in a thesis chapter without flattening the thesis into one file.

## 4. Projects, templates, and files

### 4.1 New documents

**File → New** offers seven ready-to-write templates: four general-purpose options and three university options from the repository. Show the university templates as separately selectable options, not replacements for the general-purpose templates. The chooser uses descriptive names and shows template-specific toolchain requirements; users do not need to know which `.cls` file to pick.

| Template | Initial project |
|---|---|
| Assignment | Title and author fields, followed by a first problem or section |
| Paper | Title, author, abstract, and a first section; ready to add citations |
| Thesis | Root document, front matter, and at least one separately stored chapter |
| Letter | Sender, recipient, date, salutation, body, and closing |
| University Article | Generate a ready-to-edit `main.tex` with starter content and `\documentclass{uniarticle}`. Copy [`uniarticle.cls`](../templates/uniarticle.cls) into the project. |
| University Report | Generate a ready-to-edit `main.tex` with starter content and `\documentclass{unireport}`. Copy [`unireport.cls`](../templates/unireport.cls) into the project. |
| University Final Year Project (FYP) | Copy the [university FYP project](../templates/uni-fyp-template/) and open `main.tex` as the root. Preserve its `fict.cls`, front matter, chapters, appendices, assets, and `references.bib` with their relative paths intact. |

Each selection creates an independent project at the chosen destination. It must not edit the bundled originals, rely on files in the app bundle after creation, or overwrite an existing project without confirmation. Each project must compile outside the editor with its documented toolchain. Missing build dependencies must not block project creation, editing, or saving.

### 4.2 Existing projects

- Open a `.tex` file or a project folder. Recognize a root document and follow ordinary `\input` and `\include` relationships.
- If multiple root documents are plausible, ask the user which to open. Do not silently compile the wrong document.
- Show the assembled document in reading order while retaining the identity of each underlying file. Editing chapter two changes its chapter file, not the root file.
- Resolve images and bibliography files using the project’s existing paths. Do not reorganize the folder on open.
- Report a missing file with its path and referring location. A missing asset must not prevent the user from correcting unrelated text.
- Detect include cycles without hanging. Dynamic includes that cannot be resolved reliably remain accessible in source mode.

### 4.3 Saving and external changes

A no-op open and save must leave project source and assets byte-for-byte unchanged. A typo correction must not reserialize its chapter, normalize its line endings, rewrap its paragraphs, or rewrite its preamble. A deliberate structural action may touch multiple files: for example, adding the first bibliographic entry may create a `.bib` file and connect it to the root document.

If a colleague or another editor changes a clean file on disk, reload it and update affected views. If the file also has unsaved local edits, do not overwrite either version. Identify the file and offer to compare, reload from disk, or save the local version separately. Recheck for external changes before writing, not just when the project window gains focus.

## 5. Editing surfaces and layout

### 5.1 Visual page

The default view is a GPUI editing surface, **not an interactive PDF**. It supports caret placement, selection, typing, deletion, clipboard operations, undo, and redo. Authors can create paragraphs, headings, lists, emphasis, and bold text without entering source mode. Text pasted into prose is treated as text; LaTeX entered in a source field is treated as source.

A click must select the content under the pointer. When the application cannot map a rendered passage to one unambiguous editable source range, it must offer source editing rather than guess which text to replace.

### 5.2 Layout during and after typing

| State | Required behavior |
|---|---|
| **Typing** | Show input immediately. Let the active paragraph wrap naturally. Do not apply a delayed typesetting result that moves the active passage, selection, or viewport. |
| **Idle** | After a short pause, reconcile the page with the latest available layout. Preserve the caret’s logical text position and keep the active passage in view. |
| **Typing resumes** | Invalidate outdated pending results. A result started two edits ago must never replace the current view. |
| **Compile fails** | Keep the current text editable. Distinguish the current draft from any last successful compiled preview. |

Start with a **proposed 750 ms idle interval** and tune it through typing tests. The requirement is uninterrupted editing, not that specific interval. Input-method composition counts as active typing even if there is a pause between key events.

### 5.3 Fidelity and exact preview

Use the compiled PDF as the reference for page size, margins, fonts, paragraph wrapping, pagination, equation layout, figure placement, and numbering. The visual surface should match it as closely as possible for supported content. Differences during typing are acceptable; persistent differences on the shipped templates should be recorded and tested, not dismissed as inherent to visual editing.

Provide **Compiled Preview** for checking the actual PDF. Distinguish **current**, **updating**, **out of date**, and **build failed** states. Never present an old PDF as the result of the current edit.

The visual renderer need not implement TeX or run LaTeX on each keystroke. An alternative renderer is acceptable if it improves interaction without changing the saved project or making misleading claims about final output.

### 5.4 Full-file source mode

**Show Source for This File** opens the file behind the selected passage, near its source location. Show the project preview beside the source and let the user hide or restore it without leaving source mode. Editing a chapter previews the assembled document, not a standalone compilation of the chapter.

Source and visual editing must operate on the same working text and undo history. Switching modes is not a save, conversion, or undo boundary. Returning to the visual view should retain the user’s place where a mapping exists.

## 6. Document features

### 6.1 Equations

- Provide **Insert Inline Equation** and **Insert Displayed Equation**.
- At rest, show formatted maths. Clicking an equation or activating it from the keyboard reveals its underlying LaTeX in place.
- Leaving a valid equation restores formatted maths. Editing an existing equation must preserve its enclosing environment and label unless the author explicitly changes them.
- If the input is incomplete or invalid, keep exactly what the user typed, mark the equation, and allow editing elsewhere. Do not silently substitute the last valid expression.
- Numbered equations must be available as cross-reference targets. Package-specific maths that cannot be rendered locally may use a marked source region; the local compiler still determines the PDF result.

### 6.2 Figures

**Insert Figure…** selects an image and inserts a figure at the current document position. A figure inspector provides width, caption, label, and placement preference. Suggested placement choices are **near here**, **top of page**, **bottom of page**, and **float page**. Explain that these are requests to the typesetter, not fixed page coordinates. Free dragging is not part of the interaction.

Reuse an image already in the project. For an external image, offer to copy it into the project so the document remains portable; never silently move the original or overwrite a same-named asset. A missing image appears as a placeholder with its expected path. Its caption, label, and source remain intact.

### 6.3 Cross-references

**Insert Reference…** offers searchable sections, figures, and equations, identified by descriptive text and label rather than number alone. Inserting a reference writes a symbolic reference to a label, not literal text such as “3.” If the author selects an unlabeled target, offer to create a unique label.

Adding an earlier figure or equation must update the displayed number after resolution without changing the reference’s target. Identify unresolved or duplicate labels. Do not silently redirect an ambiguous reference.

### 6.4 Bibliography and citations

Provide a **Bibliography** menu:

| Action | Behavior |
|---|---|
| **Add Source…** | Enter a book, article, or other supported entry. Suggest an editable citation key and detect key collisions before saving. |
| **Link Existing `.bib` File…** | Make an existing bibliography available to the document without importing it into a private database. |
| **Insert Citation…** | Search linked entries by author, title, year, or key and insert a citation at the caret. |
| **Insert Bibliography Here** | Add the document’s bibliography output at the selected location when the project does not already define it. Avoid duplicate output. |

From a blank template, adding the first source must create or select a project-local `.bib` file and configure it so the cited work appears in the exported bibliography. If the document already has a bibliography setup, reuse it. Adding one entry must not reorder existing entries, rewrite unrelated fields, or switch bibliography systems.

**Proposed compatibility baseline:** use one documented bibliography setup where a template does not already supply one. The University Final Year Project must retain its existing `biblatex` setup and use its `references.bib`. Recognize conventional BibTeX and `biblatex` projects. If the editor cannot safely modify a custom setup, allow source editing and explain what remains to be connected. Never add a competing preamble configuration merely to make the menu action succeed.

### 6.5 Unsupported LaTeX

Show an unsupported construct as a marked, source-editable region. Preserve its exact source unless the user edits it. If its boundaries cannot be inferred safely, widen the source region to a reliably bounded enclosing construct rather than risk modifying adjacent content.

An unsupported construct is not necessarily invalid LaTeX. A custom command may appear as source in the editor and compile correctly in the PDF. Diagnostics must distinguish **not visually supported** from **compiler error**.

## 7. Compilation, export, and diagnostics

- Detect the locally installed toolchain and allow the user to select its location if discovery fails. Do not bundle TeX, automatically install packages, or require a network service.
- Document a tested build setup for each shipped template, including the compiler and any required fonts, packages, and helper tools. Use a `fontspec`-compatible engine for University Article and University Report and document their Fira Sans and JetBrains Mono requirements. Use LuaLaTeX for University Final Year Project and support its existing bibliography and glossary build steps. Respect a supported existing project configuration rather than silently changing engines. The app must not automatically run template-supplied build scripts or enable shell escape to satisfy a dependency.
- Build the selected root against a consistent snapshot of current edits, including unsaved chapter and bibliography changes. Preview must not force a save over the user’s working files.
- Run compilation away from the UI thread. Allow cancellation. Resolve references and bibliography passes before reporting a successful final build; distinguish warnings such as unresolved citations from fatal errors.
- Keep intermediate files out of the source tree by default. Export the PDF to a user-chosen destination only after a successful build. A failed export must not destroy an existing PDF.
- Report errors with a plain-language summary, file and line when available, a way to open the source location, and access to the compiler log.
- If TeX is missing, opening, editing, and saving remain available. Compiled preview and export explain what is missing and how to retry.
- Treat unfamiliar projects as untrusted. Opening one must not execute build hooks or project-supplied commands. Require trust before compiling it, disable shell escape by default, and do not silently enable it to accommodate a package.

## 8. Implementation architecture

These are design constraints, not a commitment to a specific parser or rendering library.

| Component | Responsibility |
|---|---|
| **Project and source store** | Own file contents, paths, revisions, unsaved edits, undo transactions, disk conflict detection, and saves. This is the only component that changes document source. |
| **LaTeX document model** | Derive structure and source ranges from the working text. Index includes, headings, figures, equations, labels, and citations. Retain unknown syntax rather than normalizing it away. |
| **Editing commands** | Translate an author action into a minimal source edit or a grouped edit across files. Visual and source modes use the same transaction mechanism. |
| **GPUI presentation** | Display and edit pages; handle selection, keyboard input, source mode, inspectors, menus, diagnostics, and preview state. |
| **Layout and compilation** | Produce provisional layout and compiled output from revision-tagged snapshots. Publish a result only when its inputs still match the active project revision. |

**Key decision:** derive the visual model from the source; do not generate the entire source from a simplified visual model on save. Whole-document generation would make preservation of comments, custom commands, whitespace, and external edits depend on the editor understanding all of LaTeX.

Use source-backed anchors for carets and selections rather than page coordinates. Page locations change when text reflows; the word the author is editing should not. Exact preview navigation may use compiler source mappings where available, but visual edit correctness must not depend on those mappings being character-accurate.

## 9. Quality and recovery requirements

- **Responsiveness:** typing, caret movement, and selection must not wait for TeX. As an initial engineering target, measure 95th-percentile keystroke-to-display latency against 50 ms on a documented reference Mac and multi-chapter fixture. This is a proposed target, not a measured result.
- **Document safety:** save changed files using safe replacement. Group multi-file actions into one logical undo step. If part of a save fails, report which files were written and retain the remaining unsaved work.
- **Recovery:** after abnormal termination, offer recoverable unsaved text separately from the on-disk project. Do not automatically overwrite a colleague’s newer changes.
- **Accessibility:** support keyboard-only authoring for the core workflow, visible focus, macOS text input and composition, and meaningful accessibility labels for equations, figures, controls, and errors. Do not convey stale previews or errors by color alone.
- **Privacy and portability:** editing and compilation operate locally. App-specific preferences and caches must not be necessary to open or compile a shared project.

## 10. Release acceptance tests

| ID | Test | Pass condition |
|---|---|---|
| A01 | Choose each of the seven templates from **File → New** on a Mac with its documented dependencies. | Each opens on an editable page and exports a valid PDF without manual source changes. Each university project uses the expected local class file; the FYP project retains its original file layout and resolves its figures, glossary, and bibliography. Editing a generated project leaves the bundled template unchanged. |
| A02 | Open and save a multi-file fixture containing comments, macros, mixed formatting, and a `.bib` file. | A byte comparison finds no changes to project source or assets. |
| A03 | Correct one typo visually in an included chapter. | The diff contains only that correction in that chapter file. |
| A04 | Type across a page boundary while an earlier layout request finishes. Repeat during input-method composition. | No stale result moves the active passage, disrupts composition, or drops input. After idle reconciliation, the caret remains at the same logical text position. |
| A05 | Edit a chapter in source mode, hide and restore its side preview, then return to visual mode. | Both surfaces show the same edit, the preview uses the project root, and undo reverses the change once. |
| A06 | Edit inline and numbered displayed equations; leave one incomplete. | Valid input renders on exit. Invalid input survives navigation and saving. Existing labels remain intact. |
| A07 | Insert a captioned figure and reference it; then add another figure before it. | The reference still identifies the intended figure, and the final PDF shows the updated number. |
| A08 | Start a paper with no `.bib` file, add an article through the menu, cite it, and export. Repeat with a linked existing `.bib` file. | Both PDFs contain the citation and bibliography entry. Existing unrelated entries are unchanged. |
| A09 | Open a project containing a valid custom macro unsupported by the visual editor. | The region is marked and source-editable; unrelated edits preserve the macro; it still compiles with its original meaning. |
| A10 | Change a chapter in an external editor, first while clean and then while locally modified. | Clean changes reload. Conflicts are surfaced without silent data loss. The returned project opens in either editor. |
| A11 | Open without TeX; separately test a failed build and a missing image. | Text remains editable and savable. Each problem is identifiable. No stale preview is labeled current and no previous export is overwritten on failure. |
| A12 | Compare settled pages against compiled output for all templates, including a page break, equation, float, and bibliography. | Record differences in line breaks, pagination, placement, and numbering. Incorrect resolved references or missing content block release; known visual deviations are documented. |
| A13 | Open an unfamiliar project containing build configuration. | Opening alone runs no project commands. Compilation requires trust and does not silently enable shell escape. |
| A14 | Complete the core authoring workflow using only the keyboard, then compile the saved project outside the app. | All required actions are reachable; the project compiles without app-private files. |

## 11. Delivery sequence

1. **Prove the editing model.** Open a two-file document, type across a page boundary, apply delayed layout, save, and inspect the diff. Do not expand feature work until caret stability and source preservation both hold.
2. **Build the document editor.** Deliver templates, project navigation, prose editing, source mode with hideable preview, undo, safe saves, and unsupported-source regions.
3. **Complete technical authoring.** Deliver equations, figure controls, labels, cross-references, the bibliography menu, and citations.
4. **Qualify the release.** Verify local compilation and export, external-edit conflicts, recovery, keyboard access, performance, and fidelity against the acceptance fixtures.

The minimum macOS version, tested TeX distribution, default engine, bibliography backend, and renderer library remain implementation selections. Record them before release and use them in the test matrix. A renderer change is acceptable; sacrificing source preservation or interrupting typing to accommodate it is not.
