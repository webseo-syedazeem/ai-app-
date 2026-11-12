import { env, hasEmailConfig } from '../config/env.js';

export interface EmailSendResult {
  sent: boolean;
  configured: boolean;
  provider: 'resend' | 'none';
  id?: string;
  reason?: string;
}

export interface DigestReportStats {
  periodLabel: string;
  tasksCompleted: number;
  tasksPending: number;
  goalsCompleted: number;
  totalGoals: number;
  upcomingReminders: number;
  monthlySpent: number;
  monthlyLimit: number;
  currency: string;
  memoryCount: number;
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function wrapEmailLayout(title: string, bodyHtml: string): string {
  return `<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8" /><title>${escapeHtml(title)}</title></head>
<body style="margin:0;padding:24px;background:#FBF7F1;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#1F2330;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0">
    <tr>
      <td align="center">
        <table role="presentation" width="560" cellspacing="0" cellpadding="0" style="max-width:560px;width:100%;background:#FFFFFF;border:1px solid #EBE3D6;border-radius:20px;overflow:hidden;">
          <tr>
            <td style="background:linear-gradient(135deg,#475BE0,#667DFF);padding:24px 28px;color:#FFFFFF;">
              <div style="font-size:12px;letter-spacing:0.12em;text-transform:uppercase;opacity:0.85;font-weight:700;">AI Daily Helper</div>
              <div style="font-size:22px;font-weight:800;margin-top:6px;">${escapeHtml(title)}</div>
            </td>
          </tr>
          <tr>
            <td style="padding:28px;line-height:1.6;font-size:15px;color:#2E3342;">
              ${bodyHtml}
            </td>
          </tr>
          <tr>
            <td style="padding:16px 28px;background:#FAF5EC;border-top:1px solid #EFE7DA;font-size:12px;color:#7B756B;">
              Sent by AI Daily Helper · Manage email delivery anytime inside Settings &rarr; Email Reports.
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

/** Dispatches a transactional email via Resend when RESEND_API_KEY is configured. */
export async function sendEmail(params: {
  to: string;
  subject: string;
  html: string;
  text: string;
}): Promise<EmailSendResult> {
  if (!hasEmailConfig()) {
    return {
      sent: false,
      configured: false,
      provider: 'none',
      reason: 'RESEND_API_KEY is not configured on the server.',
    };
  }

  try {
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${env.resendApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: env.emailFrom,
        to: [params.to],
        subject: params.subject,
        html: params.html,
        text: params.text,
      }),
    });

    const data = (await response.json().catch(() => ({}))) as { id?: string; message?: string };
    if (!response.ok) {
      return {
        sent: false,
        configured: true,
        provider: 'resend',
        reason: data.message || `Email provider returned HTTP ${response.status}`,
      };
    }

    return {
      sent: true,
      configured: true,
      provider: 'resend',
      id: data.id,
    };
  } catch (error) {
    return {
      sent: false,
      configured: true,
      provider: 'resend',
      reason: error instanceof Error ? error.message : 'Network error sending email',
    };
  }
}

/** Sends a 6-digit password reset code valid for 15 minutes. */
export async function sendPasswordResetEmail(params: {
  to: string;
  fullName: string;
  code: string;
}): Promise<EmailSendResult> {
  const safeName = escapeHtml(params.fullName || 'there');
  const safeCode = escapeHtml(params.code);
  const body = `
    <p style="margin:0 0 14px;">Hi ${safeName},</p>
    <p style="margin:0 0 18px;">Use this 6-digit verification code in <strong>AI Daily Helper</strong> to set a new password. It expires in 15 minutes.</p>
    <div style="margin:20px 0;padding:18px;background:#F3F5FF;border:1px solid #DCE2FF;border-radius:14px;text-align:center;font-size:32px;font-weight:800;letter-spacing:8px;color:#475BE0;">
      ${safeCode}
    </div>
    <p style="margin:0;color:#6E675C;font-size:13px;">If you didn't request this reset, you can safely ignore this email.</p>
  `;

  return sendEmail({
    to: params.to,
    subject: `${params.code} is your AI Daily Helper password reset code`,
    html: wrapEmailLayout('Reset your password', body),
    text: `Hi ${params.fullName || 'there'}, your AI Daily Helper password reset code is ${params.code}. It expires in 15 minutes.`,
  });
}

/** Sends a formatted productivity and spending digest email. */
export async function sendDigestReportEmail(params: {
  to: string;
  fullName: string;
  stats: DigestReportStats;
}): Promise<EmailSendResult> {
  const { stats } = params;
  const safeName = escapeHtml(params.fullName || 'there');
  const safePeriod = escapeHtml(stats.periodLabel);
  const budgetLine = `${escapeHtml(stats.currency)} ${stats.monthlySpent.toLocaleString()} / ${escapeHtml(stats.currency)} ${stats.monthlyLimit.toLocaleString()}`;

  const body = `
    <p style="margin:0 0 14px;">Hi ${safeName},</p>
    <p style="margin:0 0 18px;">Here is your <strong>${safePeriod}</strong> progress snapshot from AI Daily Helper:</p>
    <table role="presentation" width="100%" cellspacing="0" cellpadding="8" style="border-collapse:collapse;background:#FAF7F2;border:1px solid #EAE2D6;border-radius:14px;">
      <tr><td style="border-bottom:1px solid #EAE2D6;"><strong>Tasks completed</strong></td><td align="right" style="border-bottom:1px solid #EAE2D6;color:#475BE0;font-weight:700;">${stats.tasksCompleted} (${stats.tasksPending} active)</td></tr>
      <tr><td style="border-bottom:1px solid #EAE2D6;"><strong>Goals achieved</strong></td><td align="right" style="border-bottom:1px solid #EAE2D6;color:#475BE0;font-weight:700;">${stats.goalsCompleted} / ${stats.totalGoals}</td></tr>
      <tr><td style="border-bottom:1px solid #EAE2D6;"><strong>Upcoming reminders</strong></td><td align="right" style="border-bottom:1px solid #EAE2D6;color:#475BE0;font-weight:700;">${stats.upcomingReminders}</td></tr>
      <tr><td style="border-bottom:1px solid #EAE2D6;"><strong>Budget tracked</strong></td><td align="right" style="border-bottom:1px solid #EAE2D6;color:#475BE0;font-weight:700;">${budgetLine}</td></tr>
      <tr><td><strong>Saved memories</strong></td><td align="right" style="color:#475BE0;font-weight:700;">${stats.memoryCount}</td></tr>
    </table>
    <p style="margin:18px 0 0;color:#6E675C;font-size:13px;">Open AI Daily Helper to review your folders, voice notes, and upcoming reminders.</p>
  `;

  return sendEmail({
    to: params.to,
    subject: `Your AI Daily Helper ${stats.periodLabel}`,
    html: wrapEmailLayout(stats.periodLabel, body),
    text: `${stats.periodLabel} — Tasks done: ${stats.tasksCompleted} (${stats.tasksPending} active), Goals met: ${stats.goalsCompleted}/${stats.totalGoals}, Upcoming reminders: ${stats.upcomingReminders}, Budget: ${stats.currency} ${stats.monthlySpent} / ${stats.monthlyLimit}, Memories: ${stats.memoryCount}.`,
  });
}
