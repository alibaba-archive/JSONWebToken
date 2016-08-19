# JSON Web Token

Swift implementation of [JSON Web Token](https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-32).

## Usage

```swift
import JSONWebToken
```

### Encoding a claim

```swift
JWT.encode(["my": "payload"], algorithm: .HS256("secret"))
```

#### Building a JWT with the builder pattern

```swift
JWT.encode(.HS256("secret")) { builder in
  builder.issuer = "fuller.li"
  builder.issuedAt = NSDate()
  builder["custom"] = "Hi"
}
```

### Decoding a JWT

When decoding a JWT, you must supply one or more algorithms and keys.
```swift
try JWT.decode("eyJh...5w", algorithms: [.HS256("secret"), .HS256("secret2"), .HS512("secure")])
```

#### Supported claims

The library supports validating the following claims:

- Issuer (`iss`) Claim
- Expiration Time (`exp`) Claim
- Not Before (`nbf`) Claim
- Issued At (`iat`) Claim
- Audience (`aud`) Claim

### Algorithms

This library supports the following algorithms:

- None - Unsecured JWTs
- HS256 - HMAC using SHA-256 hash algorithm (default)
- HS384 - HMAC using SHA-384 hash algorithm
- HS512 - HMAC using SHA-512 hash algorithm
