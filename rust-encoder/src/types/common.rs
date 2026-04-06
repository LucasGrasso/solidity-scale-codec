use parity_scale_codec::{Decode, Encode};

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Example {
    pub name: &'static str,
    pub hex: String,
}

pub fn encode_example<T>(name: &'static str, value: T) -> Example
where
    T: Encode + Decode + PartialEq + core::fmt::Debug,
{
    let encoded = value.encode();
    let mut input: &[u8] = &encoded;
    let decoded = T::decode(&mut input).expect(name);
    assert!(input.is_empty(), "{name} left trailing bytes after decode");
    assert_eq!(decoded, value, "{name} did not round-trip");

    Example {
        name,
        hex: hex::encode(encoded),
    }
}
