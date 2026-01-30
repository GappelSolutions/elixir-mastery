# Strings & Binaries

**Usefulness: 9/10** - Strings are binaries. Understanding this unlocks powerful parsing.

## Strings Are Binaries

```elixir
"hello" == <<104, 101, 108, 108, 111>>  # true

# UTF-8 encoded
"héllo" == <<104, 195, 169, 108, 108, 111>>  # true

# String length vs byte size
String.length("héllo")  # 5 (characters)
byte_size("héllo")      # 6 (bytes, é = 2 bytes)
```

## String Functions

```elixir
# Case
String.upcase("hello")      # "HELLO"
String.downcase("HELLO")    # "hello"
String.capitalize("hello")  # "Hello"

# Trim
String.trim("  hello  ")        # "hello"
String.trim_leading("  hello")  # "hello"
String.trim_trailing("hello  ") # "hello"

# Split & Join
String.split("a,b,c", ",")           # ["a", "b", "c"]
String.split("hello world")          # ["hello", "world"]
Enum.join(["a", "b", "c"], "-")      # "a-b-c"

# Replace
String.replace("hello", "l", "L")        # "heLLo"
String.replace("hello", "l", "L", global: false)  # "heLlo"

# Contains
String.contains?("hello", "ell")  # true
String.contains?("hello", ["x", "el"])  # true (any)

# Starts/Ends
String.starts_with?("hello", "hel")  # true
String.ends_with?("hello", "lo")     # true

# Slice
String.slice("hello", 1..3)   # "ell"
String.slice("hello", 1, 3)   # "ell"
String.at("hello", 1)         # "e"

# Pad
String.pad_leading("42", 5, "0")   # "00042"
String.pad_trailing("hi", 5)      # "hi   "

# Reverse
String.reverse("hello")  # "olleh"
```

## Interpolation & Sigils

```elixir
name = "Alice"
"Hello, #{name}!"  # "Hello, Alice!"

# Sigils
~s(string with "quotes")     # "string with \"quotes\""
~S(no #{interpolation})      # "no \#{interpolation}"

# Heredoc
"""
Multi-line
string
"""
```

## Binary Pattern Matching

The real power. Parse binary data elegantly.

```elixir
# Basic extraction
<<first, rest::binary>> = "hello"
# first = 104 (ASCII 'h')
# rest = "ello"

# Fixed size
<<head::binary-size(2), tail::binary>> = "hello"
# head = "he"
# tail = "llo"

# Integer extraction
<<a::16, b::16>> = <<1, 2, 3, 4>>
# a = 258 (0x0102)
# b = 772 (0x0304)

# Endianness
<<value::32-big>> = <<0, 0, 1, 0>>     # 256
<<value::32-little>> = <<0, 1, 0, 0>>  # 256

# Bits
<<a::1, b::3, c::4>> = <<0b10110101>>
# a = 1, b = 5, c = 5

# UTF-8 codepoints
<<codepoint::utf8, rest::binary>> = "héllo"
# codepoint = 104 (h)
```

## Building Binaries

```elixir
<<1, 2, 3>>                    # 3 bytes
<<256::16>>                    # 2 bytes (big endian)
<<256::16-little>>             # 2 bytes (little endian)
<<"hello", 0, "world">>        # null-separated
<<head::binary, tail::binary>> # concatenate
```

## Parsing Examples

### HTTP Header

```elixir
def parse_header(<<"Content-Length: ", rest::binary>>) do
  {length, _} = Integer.parse(rest)
  {:content_length, length}
end

def parse_header(<<"Content-Type: ", rest::binary>>) do
  {:content_type, String.trim(rest)}
end
```

### PNG File

```elixir
def parse_png(<<
  0x89, "PNG", 0x0D, 0x0A, 0x1A, 0x0A,
  _length::32,
  "IHDR",
  width::32,
  height::32,
  _rest::binary
>>) do
  {:ok, %{width: width, height: height}}
end

def parse_png(_), do: {:error, :not_png}
```

### Network Packet

```elixir
def parse_packet(<<
  version::4,
  header_length::4,
  _tos::8,
  total_length::16,
  _rest::binary
>>) do
  %{
    version: version,
    header_length: header_length * 4,
    total_length: total_length
  }
end
```

## Charlists (Legacy)

```elixir
# Single quotes = charlist (list of integers)
'hello' == [104, 101, 108, 108, 111]  # true

# Double quotes = binary string
"hello" == <<104, 101, 108, 108, 111>>  # true

# Conversion
to_string('hello')     # "hello"
to_charlist("hello")   # 'hello'

# Erlang interop often needs charlists
:os.cmd('ls -la')
```

## Regex

```elixir
# Match
String.match?("hello", ~r/ell/)  # true

# Named captures
regex = ~r/(?<first>\w+)@(?<domain>\w+)/
Regex.named_captures(regex, "user@example")
# %{"domain" => "example", "first" => "user"}

# Replace
String.replace("hello", ~r/[aeiou]/, "*")  # "h*ll*"

# Split
String.split("a1b2c3", ~r/\d/)  # ["a", "b", "c"]

# Scan (find all)
Regex.scan(~r/\d+/, "a1b23c456")  # [["1"], ["23"], ["456"]]
```

---

## Exercises

### Exercise 1: CSV Parser
```elixir
# Parse CSV line handling quoted fields
# parse_csv_line(~s|name,"city, state",age|)
# => ["name", "city, state", "age"]

defmodule CSV do
  def parse_line(line) do
    # Your code here
  end
end
```

### Exercise 2: URL Parser
```elixir
# Parse URL into components using pattern matching
# parse("https://user:pass@example.com:8080/path?query=1")
# => %{scheme: "https", user: "user", ...}

defmodule URL do
  def parse(url) do
    # Your code here
  end
end
```

### Exercise 3: Binary Protocol
```elixir
# Define a simple message protocol:
# - 1 byte: message type
# - 2 bytes: payload length
# - N bytes: payload
# Implement encode/decode

defmodule Protocol do
  def encode(type, payload) do
    # Your code here
  end

  def decode(binary) do
    # Your code here
  end
end
```

---

## Common Mistakes

### Byte vs Character

```elixir
# BAD - assumes 1 byte = 1 character
binary_part("héllo", 0, 2)  # "h\xC3" (corrupted)

# GOOD - use String functions for UTF-8
String.slice("héllo", 0, 2)  # "hé"
```

### String Concatenation in Loops

```elixir
# BAD - O(n²) because strings are immutable
Enum.reduce(list, "", fn x, acc -> acc <> x end)

# GOOD - use IO lists
list |> Enum.join()
# or
list |> IO.iodata_to_binary()
```
