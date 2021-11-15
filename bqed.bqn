While ← {𝕩{𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}𝕨@}´

# Fetch terminal width and height using `tput`
# Evaluate with •BQN to convert strings to integers
w←•BQN 1⊑•SH "tput"‿"cols"
h←•BQN 1⊑•SH "tput"‿"lines"

# Open file contents
f ← ⟨""⟩

# Reshape file contents into a screen size matrix
Scrn ← ∘‿w⊸⥊·∾w⊸↑¨

# ANSI escape code
ansiesc ← @+27
enter ← @+13
c_q ← @+17
tab ← @+9
backspace ← @+127

# Current cursor position
⟨cx, cy⟩ ← 1‿1

# Laminate array of strings with ANSI escape and concatenate them together
Ansi ← ∾ansiesc⊸∾⌜

# Create a new line: update cursor and add line to `f`
NewLine ← {𝕊: cx↩1 ⋄ cy↩(h-1)⌊cy+1 ⋄ f↩f∾<""}

# Move cursor to a specific position
CursorTo ← •OutRaw∘(ansiesc∾"["∾(•Fmt 1⊸⊑)∾";"∾(•Fmt ⊑)∾"H"∘⊢)

# Insert character (right argument) to left argument at position `cx`
InsertChar ← {𝕨𝕊𝕩: ((cx-1)↑𝕨)∾𝕩∾((cx-1)↓𝕨)}

# Put character to screen, update cursor
PutChar ← {𝕊𝕩: f↩𝕩{InsertChar⟜𝕨⌾((cy-1)⊸⊑)𝕩}f ⋄ cx↩cx+1}

DrawEditor ← {𝕊𝕩: CursorTo 1‿1 ⋄ •OutRaw¨𝕩 ⋄ CursorTo cx‿cy}

# Restore terminal state and exit
Quit ← {•SH "stty"‿"-raw"‿"echo" ⋄ •Exit 𝕩}

PutTab ← {𝕊: PutChar "        " ⋄ cx↩cx+7 }

PutBackspace ← {𝕊:
  # Current line index
  ci ← cy-1
  # Current line
  cl ← (cy-1)⊑f
  {𝕊:
    # Index where to delete. Complex because if we're on the first column,
    # we need to use a high value to produce a mask that does not delete anything
    i ← {1+≠cl}⍟{(cx-1)≤0} cx-2
    # Boolean mask that has the current character as 0 and everything else as 1
    # TODO: There most likely exists a better way to do this. This is way too complex.
    m ← i{¬»⍟𝕨 1∾(1-˜𝕩)⥊0}≠cl
    # Filter out the corresponding line in `f`
    f ↩ m⊸/⌾(ci⊸⊑)f
    # Update cursor
    cx ↩ (cx-1)⌈1
  }⍟(0<≠cl) @ # Do above only if the line has content

  # TODO: For the future: should wrap to a previous line if we're at the beginning of the line.
  #                       should remove an empty line if we're at the beginning of the line.
}

HandleEsc ← {
  "[": HandleEsc •GetChar @ ;
  # Cursor movement
  "A": cy ↩ (cy-1)⌈1  ⋄ cx ↩ cx⌊1+≠f⊑˜(cy-1) ; # Up
  "B": cy ↩ (cy+1)⌊≠f ⋄ cx ↩ cx⌊1+≠f⊑˜(cy-1) ; # Down
  "C": cx ↩ (cx+1)⌊1+≠f⊑˜cy-1                ; # Right
  "D": cx ↩ (cx-1)⌈1                         ; # Left
  𝕩: PutChar •Fmt (⊑𝕩-@)
}

Esc ← {𝕊: HandleEsc •GetChar @ }

# Special keycodes to react to
keys ← ansiesc‿c_q‿tab‿backspace‿enter

# List of functions corresponding indices of `keys`
kfns ← Esc‿Quit‿PutTab‿PutBackspace‿NewLine‿PutChar

# Get function for keycode
Kfn ← ⊑keys⊸⊐

# Status bar contents
StatusStr ← {𝕊:
  style ← ansiesc∾"[100;37m"
  s ← "<" ∾ (•Fmt cx) ∾ "," ∾ (•Fmt cy) ∾ ">" ∾ " | <C-q> to exit"
  pad ← (w-≠s)/" "
  style∾s∾pad∾ansiesc∾"[0m"
}

DrawStatus ← {𝕊: CursorTo 1‿h ⋄ •OutRaw StatusStr @ ⋄ CursorTo cx‿cy}

# Put terminal to raw mode, disable echo
•SH "stty"‿"raw"‿"-echo"

# Clear screen and position cursor to top
•OutRaw Ansi "[2J"‿"[H"

While 1‿{𝕤
  DrawEditor (Scrn f)
  DrawStatus @

  # Get a character and run a function for the input
  Kfn◶kfns •GetChar @
}
