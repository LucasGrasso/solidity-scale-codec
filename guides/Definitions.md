> Note: These definitions were taken from https://github.com/w3f/polkadot-spec/blob/main/docs. They are provided here for reference. All credits to respective authors.

# SCALE

The Polkadot Host uses _Simple Concatenated Aggregate Little-Endian” (SCALE) codec_ to encode byte arrays as well as other data structures. SCALE provides a canonical encoding to produce consistent hash values across their implementation, including the Merkle hash proof for the State Storage.

## Decoding

$\text{Dec}_{{\text{SC}}}{\left({d}\right)}$ refers to the decoding of a blob of data. Since the SCALE codec is not self-describing, it’s up to the decoder to validate whether the blob of data can be deserialized into the given type or data structure.

It’s accepted behavior for the decoder to partially decode the blob of data. This means any additional data that does not fit into a data structure can be ignored.

> caution
> Considering that the decoded data is never larger than the encoded message, this information can serve as a way to validate values that can vary in size, such as [sequences](#sequence). The decoder should strictly use the size of the encoded data as an upper bound when decoding in order to prevent denial of service attacks.

# Notation

- Let $\mathbb{{B}}$ be the set of all byte sequences.
- Let $x \in \mathbb{{B}}$, $x_i$ denotes the $i$-th byte of $x$, and $x_i^j$ denotes the $j$-th bit of the $i$-th byte of $x$.

# Definitions

## Little Endian

By the **little-endian** representation of a non-negative integer, ${I}$, represented as

$$
{I}={\left({B}_{{n}}\ldots{B}_{{0}}\right)}_{{256}}
$$

in base 256, we refer to a byte array ${B}={\left({b}_{{0}},{b}_{{1}},\ldots,{b}_{{n}}\right)}$ such that

$$
{b}_{{i}}\:={B}_{{i}}
$$

Accordingly, we define the function ${\mathsf{\text{Enc}}}_{{{\mathsf{\text{LE}}}}}$:

$$
{\mathsf{\text{Enc}}}_{{{\mathsf{\text{LE}}}}}:{\mathbb{{Z}}}^{+}\rightarrow{\mathbb{{B}}};{\left({B}_{{n}}\ldots{B}_{{0}}\right)}_{{256}}{\mid}\rightarrow{\left({B}_{{{0},}}{B}_{{1}},\ldots,{B}_{{n}}\right)}
$$

## Scale Types

### Fixed Length Integers

The SCALE codec, $\text{Enc}_{{\text{SC}}}$, for fixed length integers not defined here otherwise, is equal to the little-endian encoding of those values.

### Tuple

The **SCALE codec** for **Tuple**, ${T}$, such that:

$$
{T}\:={\left({A}_{{1}},\ldots{A}_{{n}}\right)}
$$

Where ${A}_{{i}}$’s are values of **different types**, is defined as:

$$
\text{Enc}_{{\text{SC}}}{\left({T}\right)}\:=\text{Enc}_{{\text{SC}}}{\left({A}_{{1}}\right)}\text{||}\text{Enc}_{{\text{SC}}}{\left({A}_{{2}}\right)}\text{||}\ldots\text{||}\text{Enc}_{{\text{SC}}}{\left({A}_{{n}}\right)}
$$

In the case of a tuple (or a structure), the knowledge of the shape of data is not encoded even though it is necessary for decoding. The decoder needs to derive that information from the context where the encoding/decoding is happening.

### Varying Data Type

> This library does not provide means for encoding/decoding varying data types, but the definitions are provided here for completeness and reference. The implementation is left to the user of the library.

We define a **varying data** type to be an ordered set of data types.

$$
{\mathcal{{T}}}={\left\lbrace{T}_{{1}},\ldots,{T}_{{n}}\right\rbrace}
$$

A value ${A}$ of varying data type is a pair ${\left({A}_{{\text{Type}}},{A}_{{\text{Value}}}\right)}$ where ${A}_{{\text{Type}}}={T}_{{i}}$ for some ${T}_{{i}}\in{\mathcal{{T}}}$ and ${A}_{{\text{Value}}}$ is its value of type ${T}_{{i}}$, which can be empty. We define $\text{idx}{\left({T}_{{i}}\right)}={i}-{1}$, unless it is explicitly defined as another value in the definition of a particular varying data type.

The SCALE codec for value ${A}={\left({A}_{{\text{Type}}},{A}_{{\text{Value}}}\right)}$ of varying data type ${\mathcal{{T}}}={\left\lbrace{T}_{{i}},\ldots{T}_{{n}}\right\rbrace}$, formally referred to as $\text{Enc}_{{\text{SC}}}{\left({A}\right)}$ is defined as follows:

$$
\text{Enc}_{{\text{SC}}}{\left({A}\right)}\:=\text{Enc}_{{\text{SC}}}{\left(\text{idx}{\left({A}_{{\text{Type}}}\right)}\text{||}\text{Enc}_{{\text{SC}}}{\left({A}_{{\text{Value}}}\right)}\right)}
$$

The SCALE codec does not encode the correspondence between the value and the data type it represents; the decoder needs prior knowledge of such correspondence to decode the data.

### Boolean

The SCALE codec for a **boolean value** ${b}$ defined as a byte as follows:

$$
\text{Enc}_{{\text{SC}}}:{\left\lbrace\text{False},\text{True}\right\rbrace}\rightarrow{\mathbb{{B}}}_{{1}}
$$

$$
{b}\rightarrow{\left\lbrace\begin{matrix}{0}&{b}=\text{False}\\{1}&{b}=\text{True}\end{matrix}\right.}
$$

### Compact

**SCALE Length encoding** ${\text{Enc}_{{\text{SC}}}^{{\text{Len}}}}$, also known as a _compact encoding_, of a non-negative number ${n}$ is defined as follows:

$$
{\text{Enc}_{{\text{SC}}}^{{\text{Len}}}}:{\mathbb{{N}}}\rightarrow{\mathbb{{B}}}
$$

$$
{n}\rightarrow{b}\:={\left\lbrace\begin{matrix}{l}_{{1}}&{0}\le{n}<{2}^{{6}}\\{i}_{{1}}{i}_{{2}}&{2}^{{6}}\le{n}<{2}^{{14}}\\{j}_{{1}}{j}_{{2}}{j}_{{3}}{j}_{{4}}&{2}^{{14}}\le{n}<{2}^{{30}}\\{k}_{{1}}{k}_{{2}}\ldots{k}_{{m}+{1}}&{2}^{{30}}\le{n}\end{matrix}\right.}
$$

$$
{{l}_{{1}}^{{1}}}{{l}_{{1}}^{{0}}}={00}
$$

$$
{{i}_{{1}}^{{1}}}{{i}_{{1}}^{{0}}}={01}
$$

$$
{{j}_{{1}}^{{1}}}{{j}_{{1}}^{{0}}}={10}
$$

$$
{{k}_{{1}}^{{1}}}{{k}_{{1}}^{{0}}}={11}
$$

and the rest of the bits of ${b}$ store the value of ${n}$ in little-endian format in base-2 as follows:

$$
{n}\:={\left\lbrace\begin{matrix}{{l}_{{1}}^{{7}}}\ldots{{l}_{{1}}^{{3}}}{{l}_{{1}}^{{2}}}&{n}<{2}^{{6}}\\{{i}_{{2}}^{{7}}}\ldots{{i}_{{2}}^{{0}}}{{i}_{{1}}^{{7}}}..{{i}_{{1}}^{{2}}}&{2}^{{6}}\le{n}<{2}^{{14}}\\{{j}_{{4}}^{{7}}}\ldots{{j}_{{4}}^{{0}}}{{j}_{{3}}^{{7}}}\ldots{{j}_{{1}}^{{7}}}\ldots{{j}_{{1}}^{{2}}}&{2}^{{14}}\le{n}<{2}^{{30}}\\{k}_{{2}}+{k}_{{3}}{2}^{{8}}+{k}_{{4}}{2}^{{{2}\times{8}}}+\ldots+{k}_{{m}+{1}}{2}^{{{\left({m}-{1}\right)}{8}}}&{2}^{{30}}\le{n}\end{matrix}\right.}
$$

such that:

$$
{{k}_{{1}}^{{7}}}\ldots{{k}_{{1}}^{{3}}}{{k}_{{1}}^{{2}}}\:={m}-{4}
$$

Note that ${m}$ denotes the length of the original integer being encoded and does not include the extra byte describing the length. The encoding can be used for integers up to: $$2^{(63+4)8} -1 = 2^{536} -1$$

### Sequence

The **SCALE codec** for **sequence** ${S}$ such that:

$$
{S}\:={A}_{{1}},\ldots{A}_{{n}}
$$

where ${A}_{{i}}$’s are values of **the same type** (and the decoder is unable to infer value of ${n}$ from the context) is defined as:

$$
\text{Enc}_{{\text{SC}}}{\left({S}\right)}\:={\text{Enc}_{{\text{SC}}}^{{\text{Len}}}}{\left({\left|{{S}}\right|}\right)}\text{||}\text{Enc}_{{\text{SC}}}{\left({A}_{{2}}\right)}\text{||}\ldots\text{||}\text{Enc}_{{\text{SC}}}{\left({A}_{{n}}\right)}
$$

where ${\text{Enc}_{{\text{SC}}}^{{\text{Len}}}}$ is defined [here](#compact).

In some cases, the length indicator ${\text{Enc}_{{\text{SC}}}^{{\text{Len}}}}{\left({\left|{{S}}\right|}\right)}$ is omitted if the length of the sequence is fixed and known by the decoder upfront. Such cases are explicitly stated by the definition of the corresponding type.

### String

The SCALE codec for a **string value** is an [encoded sequence](#sequence) consisting of UTF-8 encoded bytes.

> This can be achieved via encoding the UTF-8 sequence as a `uint8[]` or `bytes`, which is supported by this library.

### Option Type

The **Option** type is a varying data type of ${\left\lbrace\text{None},{T}_{{2}}\right\rbrace}$ which indicates if data of ${T}_{{2}}$ type is available (referred to as _some_ state) or not (referred to as _empty_, _none_ or _null_ state). The presence of type _none_, indicated by $\text{idx}{\left({T}_{{\text{None}}}\right)}={0}$, implies that the data corresponding to ${T}_{{2}}$ type is not available and contains no additional data. Where as the presence of type ${T}_{{2}}$ indicated by $\text{idx}{\left({T}_{{2}}\right)}={1}$ implies that the data is available.

### Result Type

The **Result** type is a varying data type of ${\left\lbrace{T}_{{1}},{T}_{{2}}\right\rbrace}$ which is used to indicate if a certain operation or function was executed successfully (referred to as "ok" state) or not (referred to as "error" state). ${T}_{{1}}$ implies success, ${T}_{{2}}$ implies failure. Both types can either contain additional data or are defined as empty types otherwise.

### Dictionaries, Hashtables, Maps

SCALE codec for **dictionary** or **hashtable** D with key-value pairs
$({k}_{{i}},{v}_{{i}})$, such that:

$$
{D}\:={\left\lbrace{\left({k}_{{1}},{v}_{{1}}\right)},\ldots{\left({k}_{{n}},{v}_{{n}}\right)}\right\rbrace}
$$

is defined as the SCALE codec of ${D}$ as a sequence of key-value pairs (as tuples):

$$
\text{Enc}_{{\text{SC}}}{\left({D}\right)}\:={\text{Enc}_{{\text{SC}}}^{{\text{Size}}}}{\left({\left|{{D}}\right|}\right)}\text{||}\text{Enc}_{{\text{SC}}}{\left({k}_{{1}},{v}_{{1}}\right)}\text{||}\ldots\text{||}\text{Enc}_{{\text{SC}}}{\left({k}_{{n}},{v}_{{n}}\right)}
$$

where ${\text{Enc}_{{\text{SC}}}^{{\text{Size}}}}$ is encoded the same way as ${\text{Enc}_{{\text{SC}}}^{{\text{Len}}}}$ but argument $\text{Size}$ refers to the number of key-value pairs rather than the length.
