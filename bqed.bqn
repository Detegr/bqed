While ← {𝕩{𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}𝕨@}´

# ANSI escape code
ansiesc ← @+27
enter ← @+13

# Laminate array of strings with ANSI escape and concatenate them together
Ansi ← ∾ansiesc⊸∾⌜

# Move cursor down for one line
CursorDown ← •OutRaw∘(ansiesc∾"[1E")

# No operation
Nop ← {𝕤}

# Restore terminal state and exit
Quit ← {•SH "stty"‿"-raw"‿"echo" ⋄ •Exit 𝕩}

# Special keycodes to react to
keys ← 'q'‿enter

# List of functions corresponding indices of `keys`
kfns ← Quit‿CursorDown‿•OutRaw

# Get function for keycode
Kfn ← ⊑keys⊸⊐

# Fetch terminal width and height using `tput`
# Evaluate with •BQN to convert strings to integers
w←•BQN 1⊑•SH "tput"‿"cols"
h←•BQN 1⊑•SH "tput"‿"lines"

# Put terminal to raw mode, disable echo
•SH "stty"‿"raw"‿"-echo"

# Clear screen and position cursor to top
•OutRaw Ansi "[2J"‿"[H"

While 1‿{𝕤
  # Get a character and run a function for the input
  Kfn◶kfns •GetChar @
}
