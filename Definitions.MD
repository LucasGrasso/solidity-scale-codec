> Note: These definitions were taken from https://github.com/w3f/polkadot-spec/blob/main/docs. They are provided here for reference. All credits to respective authors.

# Notation

- Let $\mathbb{{B}}$ be the set of all byte sequences.
- For $x \in \mathbb{{B}}$, $x_i$ denotes the $i$-th byte of $x$, and $x_i^j$ denotes the $j$-th bit of the $i$-th byte of $x$.

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

> This can be achieved via encoding the UTF-8 sequence as a `uint8[]` array, which is supported by this library.
