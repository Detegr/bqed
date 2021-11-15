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

# Laminate array of strings with ANSI escape and concatenate them together
Ansi ← ∾ansiesc⊸∾⌜

# Create a new line: update cursor and add line to `f`
NewLine ← {𝕊: cx↩1 ⋄ cy↩(h-1)⌊cy+1 ⋄ f↩f∾<""}

# Move cursor to a specific position
CursorTo ← •OutRaw∘(ansiesc∾"["∾(•Fmt 1⊸⊑)∾";"∾(•Fmt ⊑)∾"H"∘⊢)

# Put character to screen, update cursor
PutChar ← {𝕊𝕩: f↩𝕩{∾⟜𝕨⌾((cy-1)⊸⊑)𝕩}f ⋄ cx↩cx+1}

DrawEditor ← {𝕊𝕩: CursorTo 1‿1 ⋄ •OutRaw¨𝕩 ⋄ CursorTo cx‿cy}

# Restore terminal state and exit
Quit ← {•SH "stty"‿"-raw"‿"echo" ⋄ •Exit 𝕩}

# Special keycodes to react to
keys ← (@+17)‿enter

# List of functions corresponding indices of `keys`
kfns ← Quit‿NewLine‿PutChar

# Get function for keycode
Kfn ← ⊑keys⊸⊐

⟨cx, cy⟩ ← 1‿1

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
