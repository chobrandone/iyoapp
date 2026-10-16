import { useState, type FormEvent } from 'react';
import { useTranslation } from 'react-i18next';

import { DEMO_ADMIN_EMAIL, DEMO_ADMIN_PASSWORD } from '@/data/demo';
import { BackendError } from '@/data/models';
import { useRepo } from '@/data/queries';
import { Button, Field, inputClass } from '@/ui/kit';

/** Email + password for staff; only profiles with role 'admin' get past it. */
export function SignInScreen() {
  const { t } = useTranslation();
  const repo = useRepo();
  const [email, setEmail] = useState(repo.isDemo ? DEMO_ADMIN_EMAIL : '');
  const [password, setPassword] = useState(repo.isDemo ? DEMO_ADMIN_PASSWORD : '');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string>();

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(undefined);
    try {
      await repo.signIn(email, password);
    } catch (err) {
      setError(
        err instanceof BackendError && err.code === 'wrong_role'
          ? t('notAdmin')
          : t('invalidCredentials'),
      );
      setBusy(false);
    }
  };

  return (
    <main className="flex min-h-full items-center justify-center p-4">
      <form
        onSubmit={submit}
        aria-labelledby="sign-in-title"
        className="flex w-full max-w-[400px] flex-col gap-4 rounded-2xl border border-line bg-white p-8"
      >
        <div className="flex items-center gap-3">
          <img src="/logo.png" alt="" width={56} height={56} className="rounded-xl" />
          <div>
            <p className="text-[25px] leading-[37px] font-bold">iyodriver</p>
            <p className="text-[10px] text-sub">{t('workspace')}</p>
          </div>
        </div>
        <div>
          <h1 id="sign-in-title" className="text-[20px] font-semibold">
            {t('signInTitle')}
          </h1>
          <p className="text-[12px] text-sub">{t('signInSubtitle')}</p>
        </div>
        <Field label={t('email')}>
          {(p) => (
            <input
              {...p}
              type="email"
              autoComplete="username"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className={inputClass}
            />
          )}
        </Field>
        <Field label={t('password')} error={error}>
          {(p) => (
            <input
              {...p}
              type="password"
              autoComplete="current-password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className={inputClass}
            />
          )}
        </Field>
        <Button type="submit" tone="primary" size={46} block loading={busy}>
          {t('signIn')}
        </Button>
        {repo.isDemo && (
          <p className="text-[11px] text-sub">
            {t('demoSignInHint', { email: DEMO_ADMIN_EMAIL, password: DEMO_ADMIN_PASSWORD })}
          </p>
        )}
      </form>
    </main>
  );
}
