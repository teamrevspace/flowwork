'use client';

import { Session } from '@/types';
import axios, { AxiosError, AxiosResponse } from 'axios';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useCallback, useEffect, useState } from 'react';

export default function JoinSessionPage({ params }: { params: { id: string } }) {
  const [sessionName, setSessionName] = useState<string | null | undefined>(undefined);
  const [networkError, setNetworkError] = useState(false);
  const router = useRouter();

  const downloadApp = async () => {
    router.push('/download');
  };

  const joinSession = useCallback(async () => {
    location.href = `flowwork://join?sessionId=${params.id}`;
  }, [params.id]);

  useEffect(() => {
    setNetworkError(false);
    axios
      .get(`https://api.flowwork.xyz/api/sessions?session_id=${params.id}`)
      .then((res: AxiosResponse<Session>) => res.data)
      .then((session) => {
        setSessionName(session.name);
      })
      .catch((err: AxiosError) => {
        if (err.code === 'ERR_NETWORK') {
          setNetworkError(true);
        } else {
          setSessionName(null);
        }
      });
  }, [params.id, router]);

  return (
    <div className='flex h-screen w-full flex-col bg-white px-6 py-8 sm:py-12'>
      <div className='flex flex-1 flex-col items-center justify-center gap-y-6'>
        <Link href='/'>
          <img className='h-24 w-24 sm:h-32 sm:w-32' src='/logo.png' />
        </Link>
        {(networkError || sessionName) && (
          <p className='text-center text-base text-[#999999] sm:text-lg'>
            You&apos;ve been invited to join a Flow Work session
          </p>
        )}
        <h1 className='text-center text-2xl font-bold text-[#2a2a2a] sm:text-4xl'>
          {networkError
            ? `Launching Flow Work 🚀`
            : sessionName
            ? `${sessionName}`
            : sessionName === null
            ? `Session not found 😔`
            : `Loading...`}
        </h1>
        {networkError || sessionName ? null : sessionName === null ? (
          <p className='text-center text-base text-[#999999] sm:text-lg'>
            Either this session doesn&apos;t exist or it has been removed.
          </p>
        ) : null}
        {(networkError || sessionName) && (
          <button
            onClick={(e) => {
              e.preventDefault();
              joinSession();
            }}
            type='button'
            className='rounded-xl border-none bg-electric-blue px-8 py-2 text-base font-medium text-white hover:bg-electric-blue-accent sm:px-12 sm:py-3 sm:text-lg'
          >
            Join session
          </button>
        )}
        {(networkError || sessionName) && (
          <p className='text-center text-sm text-[#999999] sm:text-base'>
            or copy-paste the session code:&nbsp;
            <code className='bg-silver'>{params.id}</code>
          </p>
        )}
      </div>
      <p className='text-center text-sm text-[#999999] sm:text-base'>
        Don&apos;t have Flow Work installed?&nbsp;
        <button
          onClick={(e) => {
            e.preventDefault();
            downloadApp();
          }}
          className='text-electric-blue'
        >{`Download here`}</button>
      </p>
    </div>
  );
}
