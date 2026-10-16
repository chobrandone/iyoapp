import { QueryClient, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

import { useToast } from '@/ui/toast';
import { BackendError, type AdminProfile } from './models';
import type { AdminRepository } from './repository';
import { addDays, doualaDay } from './time';

// ---------------------------------------------------------------------------
// Repository, clock and signed-in admin
// ---------------------------------------------------------------------------

const RepoContext = createContext<AdminRepository | null>(null);
const NowContext = createContext<Date>(new Date());

export function useRepo(): AdminRepository {
  const repo = useContext(RepoContext);
  if (!repo) throw new Error('useRepo outside <DataProvider>');
  return repo;
}

/** The dashboard clock: ticks every 30 s, or a fixed instant in tests and design reviews. */
export const useNow = () => useContext(NowContext);

export function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { staleTime: 30_000, refetchOnWindowFocus: true, retry: 1 },
    },
  });
}

export function DataProvider({
  repo,
  now: fixedNow,
  children,
}: {
  repo: AdminRepository;
  now?: Date;
  children: ReactNode;
}) {
  const [now, setNow] = useState(() => fixedNow ?? new Date());
  useEffect(() => {
    if (fixedNow) return;
    const id = setInterval(() => setNow(new Date()), 30_000);
    return () => clearInterval(id);
  }, [fixedNow]);
  return (
    <RepoContext.Provider value={repo}>
      <NowContext.Provider value={now}>{children}</NowContext.Provider>
    </RepoContext.Provider>
  );
}

/** undefined while the session loads, then the admin or null. */
export function useAdmin(): AdminProfile | null | undefined {
  const repo = useRepo();
  const [admin, setAdmin] = useState<AdminProfile | null | undefined>(undefined);
  useEffect(() => repo.watchAdmin(setAdmin), [repo]);
  return admin;
}

// ---------------------------------------------------------------------------
// Reads
// ---------------------------------------------------------------------------

export const keys = {
  overview: ['overview'],
  live: ['live-drivers'],
  rides: ['rides'],
  ride: (id: string) => ['ride', id],
  rentals: ['rentals'],
  drivers: ['drivers'],
  fleet: ['fleet'],
  cases: ['safety-cases'],
  admins: ['admins'],
  payments: ['payments-summary'],
  transactions: ['transactions'],
} as const;

export const useOverview = () => {
  const repo = useRepo();
  return useQuery({ queryKey: keys.overview, queryFn: () => repo.overview() });
};
export const useLiveDrivers = () => {
  const repo = useRepo();
  return useQuery({
    queryKey: keys.live,
    queryFn: () => repo.liveDrivers(),
    refetchInterval: 15_000,
  });
};
export const useRides = () => {
  const repo = useRepo();
  return useQuery({ queryKey: keys.rides, queryFn: () => repo.rides(), refetchInterval: 30_000 });
};
export const useRide = (id: string) => {
  const repo = useRepo();
  return useQuery({ queryKey: keys.ride(id), queryFn: () => repo.rideDetail(id) });
};
export const useRentals = () => {
  const repo = useRepo();
  return useQuery({ queryKey: keys.rentals, queryFn: () => repo.rentals() });
};
export const useDrivers = () => {
  const repo = useRepo();
  return useQuery({ queryKey: keys.drivers, queryFn: () => repo.drivers() });
};
export const useFleet = () => {
  const repo = useRepo();
  return useQuery({ queryKey: keys.fleet, queryFn: () => repo.fleet() });
};
export const useSafetyCases = () => {
  const repo = useRepo();
  return useQuery({
    queryKey: keys.cases,
    queryFn: () => repo.safetyCases(),
    refetchInterval: 20_000,
  });
};
export const useAdmins = () => {
  const repo = useRepo();
  return useQuery({ queryKey: keys.admins, queryFn: () => repo.admins(), staleTime: 300_000 });
};
export const usePaymentsSummary = () => {
  const repo = useRepo();
  const now = useNow();
  const today = doualaDay(now);
  return useQuery({
    queryKey: [...keys.payments, today.getTime()],
    queryFn: () => repo.paymentsSummary(addDays(today, -6), today),
  });
};
export const useTransactions = () => {
  const repo = useRepo();
  return useQuery({ queryKey: keys.transactions, queryFn: () => repo.transactions() });
};

/** Open safety cases, for the sidebar count. */
export function useOpenCases(): number {
  const { data } = useSafetyCases();
  return data?.filter((c) => c.status !== 'resolved').length ?? 0;
}

// ---------------------------------------------------------------------------
// Writes: run, toast the outcome, refresh what changed
// ---------------------------------------------------------------------------

export function useAction<A>(
  run: (repo: AdminRepository, args: A) => Promise<void>,
  options: {
    invalidate: readonly (readonly unknown[])[];
    success?: (args: A) => string;
    errors?: Record<string, string>;
  },
) {
  const repo = useRepo();
  const client = useQueryClient();
  const toast = useToast();
  const { t } = useTranslation();
  return useMutation({
    mutationFn: (args: A) => run(repo, args),
    onSuccess: async (_, args) => {
      await Promise.all(options.invalidate.map((k) => client.invalidateQueries({ queryKey: k })));
      if (options.success) toast(options.success(args));
    },
    onError: (e) => {
      const code = e instanceof BackendError ? e.code : 'internal_error';
      toast(options.errors?.[code] ?? t('actionFailed', { reason: code }), 'error');
    },
  });
}
