While ← {𝕩{𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}𝕨@}´

# ANSI escape code
ansiesc ← @+27
enter ← @+13

# Laminate array of strings with ANSI escape and concatenate them together
Ansi ← ∾ansiesc⊸∾⌜

# Move cursor down for one line
CursorDown ← {𝕊: cx↩1 ⋄ cy↩cy+1}

# Move cursor to a specific position
CursorTo ← •OutRaw∘(ansiesc∾"["∾(•Fmt 1⊸⊑)∾";"∾(•Fmt ⊑)∾"H"∘⊢)

# Put character to screen, update cursor
PutChar ← {cx↩cx+1 ⋄ •OutRaw 𝕩}

# Restore terminal state and exit
Quit ← {•SH "stty"‿"-raw"‿"echo" ⋄ •Exit 𝕩}

# Special keycodes to react to
keys ← 'q'‿enter

# List of functions corresponding indices of `keys`
kfns ← Quit‿CursorDown‿PutChar

# Get function for keycode
Kfn ← ⊑keys⊸⊐

# Fetch terminal width and height using `tput`
# Evaluate with •BQN to convert strings to integers
w←•BQN 1⊑•SH "tput"‿"cols"
h←•BQN 1⊑•SH "tput"‿"lines"

⟨cx, cy⟩ ← 1‿1

StatusStr ← {𝕊:
  style ← ansiesc∾"[100;37m"
  s ← "<" ∾ (•Fmt cx) ∾ "," ∾ (•Fmt cy) ∾ ">"
  pad ← (w-cx+≠s)/" "
  style∾s∾pad∾ansiesc∾"[0m"
}

DrawStatus ← {𝕊: CursorTo 1‿h ⋄ •OutRaw StatusStr @ ⋄ CursorTo cx‿cy}

# Put terminal to raw mode, disable echo
•SH "stty"‿"raw"‿"-echo"

# Clear screen and position cursor to top
•OutRaw Ansi "[2J"‿"[H"

While 1‿{𝕤
  DrawStatus @

  # Get a character and run a function for the input
  Kfn◶kfns •GetChar @
}
