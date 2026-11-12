import crypto from 'node:crypto';
import { env } from '../config/env.js';
import type { UserProfile } from '../types/domain.js';

export interface AuthTokenPayload {
  sub: string;
  email: string;
  iat: number;
  exp: number;
}

const TOKEN_TTL_SECONDS = 30 * 24 * 60 * 60; // 30 days

/**
 * Hashes a plaintext password with a random 16-byte salt using Node's scrypt KDF.
 */
export function hashPassword(password: string): string {
  const salt = crypto.randomBytes(16).toString('hex');
  const derived = crypto.scryptSync(password, salt, 64).toString('hex');
  return `${salt}:${derived}`;
}

/**
 * Constant-time verification of a plaintext password against a stored scrypt hash.
 */
export function verifyPassword(password: string, storedHash?: string): boolean {
  if (!storedHash) return false;
  const parts = storedHash.split(':');
  if (parts.length !== 2) return false;
  const [salt, keyHex] = parts;
  if (!salt || !keyHex) return false;
  try {
    const keyBuf = Buffer.from(keyHex, 'hex');
    const derived = crypto.scryptSync(password, salt, 64);
    if (keyBuf.length !== derived.length) return false;
    return crypto.timingSafeEqual(keyBuf, derived);
  } catch {
    return false;
  }
}

/**
 * Signs a compact HMAC-SHA256 JWT without external dependencies.
 */
export function signAuthToken(user: Pick<UserProfile, 'id' | 'email'>): string {
  const now = Math.floor(Date.now() / 1000);
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');
  const payload: AuthTokenPayload = {
    sub: user.id,
    email: user.email,
    iat: now,
    exp: now + TOKEN_TTL_SECONDS,
  };
  const body = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const signingInput = `${header}.${body}`;
  const sig = crypto.createHmac('sha256', env.jwtSecret).update(signingInput).digest('base64url');
  return `${signingInput}.${sig}`;
}

/**
 * Verifies an HMAC-SHA256 JWT and checks expiration.
 */
export function verifyAuthToken(token: string): AuthTokenPayload | null {
  const parts = token.trim().split('.');
  if (parts.length !== 3) return null;
  const [header, body, sig] = parts;
  if (!header || !body || !sig) return null;

  const signingInput = `${header}.${body}`;
  const expectedSig = crypto
    .createHmac('sha256', env.jwtSecret)
    .update(signingInput)
    .digest('base64url');

  const sigBuf = Buffer.from(sig);
  const expectedBuf = Buffer.from(expectedSig);
  if (sigBuf.length !== expectedBuf.length || !crypto.timingSafeEqual(sigBuf, expectedBuf)) {
    return null;
  }

  try {
    const decoded = JSON.parse(Buffer.from(body, 'base64url').toString('utf8')) as AuthTokenPayload;
    if (!decoded.sub || typeof decoded.exp !== 'number') return null;
    if (decoded.exp < Math.floor(Date.now() / 1000)) return null;
    return decoded;
  } catch {
    return null;
  }
}

/**
 * Removes sensitive credential fields before serializing a user profile to HTTP responses.
 */
export function sanitizeUser(user: UserProfile): Omit<UserProfile, 'password_hash'> {
  const { password_hash: _ignored, ...safe } = user;
  return safe;
}

/**
 * Signs a short-lived HMAC state token for OAuth redirect flows.
 */
export function signOAuthState(redirectUri: string): string {
  const exp = Math.floor(Date.now() / 1000) + 600;
  const payload = Buffer.from(JSON.stringify({ redirectUri, exp })).toString('base64url');
  const sig = crypto.createHmac('sha256', env.jwtSecret).update(payload).digest('base64url');
  return `${payload}.${sig}`;
}

/**
 * Verifies an OAuth state token and extracts its target app redirect URI.
 */
export function verifyOAuthState(state: string): { redirectUri: string } | null {
  const parts = state.trim().split('.');
  if (parts.length !== 2) return null;
  const [payload, sig] = parts;
  if (!payload || !sig) return null;

  const expected = crypto.createHmac('sha256', env.jwtSecret).update(payload).digest('base64url');
  const a = Buffer.from(sig);
  const b = Buffer.from(expected);
  if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) return null;

  try {
    const parsed = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')) as {
      redirectUri?: string;
      exp?: number;
    };
    if (!parsed.redirectUri || typeof parsed.exp !== 'number') return null;
    if (parsed.exp < Math.floor(Date.now() / 1000)) return null;
    return { redirectUri: parsed.redirectUri };
  } catch {
    return null;
  }
}
