'use client';

import Head from 'next/head';
import { useRef, useState } from 'react';
import clsx from 'clsx';
import posthog from 'posthog-js';
import Image from 'next/image';

import Airtable from 'airtable';
import { ResponseStatus } from '@/types';
import { useRouter } from 'next/navigation';

// Airtable API
Airtable.configure({
  apiKey: process.env.NEXT_PUBLIC_AIRTABLE_API_KEY,
});
const base = Airtable.base(process.env.NEXT_PUBLIC_AIRTABLE_BASE_ID!);
const masterTable = base(process.env.NEXT_PUBLIC_AIRTABLE_TABLE_NAME!);

// PostHog API
if (typeof window !== 'undefined') {
  posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
    api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST || 'https://app.posthog.com',
    // Enable debug mode in development
    loaded: (posthog) => {
      if (process.env.NODE_ENV === 'development') posthog.debug();
    },
  });
}

const captureClick = (name: string) => {
  posthog.capture(name, { action: 'clicked' });
};

const captureSignupMailingList = (email: string) => {
  posthog.capture('mailing list', { email, action: 'signup' });
};

export default function Home() {
  const [email, setEmail] = useState('');

  const [status, setStatus] = useState<ResponseStatus>(ResponseStatus.Waiting);
  const [loading, setLoading] = useState(false);

  const emailInputRef = useRef<HTMLInputElement>(null);

  const router = useRouter();

  const validateEmail = (email: string) => {
    const validRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/g;

    if (email === '') {
      setStatus(ResponseStatus.Waiting);
      return false;
    } else if (email.match(validRegex)) {
      setStatus(ResponseStatus.Ready);
      return true;
    } else {
      setStatus(ResponseStatus.InvalidFormat);
      return false;
    }
  };

  const checkExists = async (email: string) => {
    // email field id = fldw5UVSKhcgCWyWL
    const records = await masterTable.select({ filterByFormula: `fldw5UVSKhcgCWyWL = "${email}"` }).firstPage();

    if (records.length > 0) {
      setStatus(ResponseStatus.AlreadyExists);
      return true;
    } else {
      return false;
    }
  };

  const insertEmail = async (email: string) => {
    masterTable.create({ fldw5UVSKhcgCWyWL: email }, (err) => {
      if (err) {
        setStatus(ResponseStatus.AddFailed);
        return;
      }
      setStatus(ResponseStatus.SuccessfullyAdded);
      setEmail('');
    });
  };

  const addEmail = async (email: string) => {
    if (status === ResponseStatus.Ready) {
      setLoading(true);
      const exists = await checkExists(email);
      if (!exists) {
        insertEmail(email).finally(() => {
          captureSignupMailingList(email);
          downloadApp();
          setLoading(false);
        });
      } else {
        setStatus(ResponseStatus.AlreadyExists);
        setEmail('');
        downloadApp();
        setLoading(false);
      }
    } else {
      emailInputRef.current?.focus();
    }
  };

  const signup = async (e: any) => {
    e.preventDefault();
    addEmail(email);
  };

  const downloadApp = () => {
    captureClick('download');
    router.push('/download');
  };

  return (
    <div className='flex h-full min-h-screen w-full flex-col bg-white lg:h-screen'>
      <Head>
        <title>Flow Work</title>
        <meta name='description' content={`A social productivity tool designed to help you find your flow.`} />
        <link rel='icon' href='/favicon.ico' />
      </Head>

      <div id='nav' className='flex w-full flex-row justify-between px-12 py-8'></div>
      <div
        id='main'
        className='mx-auto flex h-full w-full flex-col items-center justify-center gap-12 sm:px-8 lg:flex-row'
      >
        <div id='hero' className='flex flex-col gap-y-5 px-6 sm:min-w-[24rem] sm:px-0'>
          <img className='h-24 w-24 sm:h-32 sm:w-32' src='/logo.png' />
          <h1 className='text-6xl font-bold text-[#001122] sm:text-7xl'>Flow Work</h1>
          <h2 className='text-xl font-medium text-[#999999]'>
            Cowork with friends in real time,
            <br />
            find your flow, and get sh*t done.
          </h2>
          <div className='flex flex-row gap-x-3'>
            {status === ResponseStatus.SuccessfullyAdded || status === ResponseStatus.AlreadyExists ? (
              <p className='flex h-[52px] items-center justify-center text-[#5a5a5a]'>
                <span>Click&nbsp;</span>
                <button
                  onClick={(e) => {
                    e.preventDefault();
                    downloadApp();
                  }}
                  className='text-electric-blue'
                >{`here`}</button>
                <span>&nbsp;to download on Mac (in public beta)</span>
              </p>
            ) : (
              <>
                <input
                  ref={emailInputRef}
                  name='email_address'
                  onChange={(e) => {
                    validateEmail(e.target.value);
                    setEmail(e.target.value);
                  }}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      signup(e);
                    }
                  }}
                  type='email'
                  value={email}
                  required={true}
                  autoComplete='off'
                  aria-label='Email address'
                  className={clsx(
                    'block w-full max-w-[360px] appearance-none rounded-xl border border-transparent bg-[#f2f2f2] px-6 py-3 leading-5 text-[#222222] shadow ring-1 ring-silver placeholder:text-black placeholder:text-opacity-25 focus:outline-none focus:ring-2',
                    (status === ResponseStatus.AddFailed || status === ResponseStatus.InvalidFormat) &&
                      'focus:ring-red-500',
                    (status === ResponseStatus.Waiting || status === ResponseStatus.Ready) && 'focus:ring-electric-blue'
                  )}
                  placeholder='name@email.com'
                />
                <button
                  onClick={(e) => signup(e)}
                  type='button'
                  className='w-2/5 whitespace-nowrap rounded-xl border-none bg-electric-blue px-5 py-3 text-lg font-medium text-white hover:bg-electric-blue-accent'
                >
                  {loading ? (
                    <div className='flex h-7 w-full items-center justify-center'>
                      <Image className='animate-spin' width={24} height={24} src='spinner.svg' alt={'Loading...'} />
                    </div>
                  ) : (
                    'Get Flow Work'
                  )}
                </button>
              </>
            )}
          </div>
        </div>
        <div id='demo' className='aspect-auto h-auto w-full sm:w-[40rem]'>
          <video
            loop
            autoPlay
            muted
            playsInline
            onContextMenu={() => false}
            preload='auto'
            className='h-full w-full bg-black object-cover sm:rounded-lg sm:shadow-2xl'
          >
            <source src={'flowwork-demo.mp4'} type='video/mp4' />
          </video>
        </div>
      </div>
      <div id='footer' className='flex w-full flex-grow flex-row items-end justify-between px-12 py-8'>
        <p className='font-medium text-metallic-gray'>
          © 2023{' '}
          <a
            href='https://rev.school'
            target='_blank'
            referrerPolicy='no-referrer'
            className='hover:underline'
            onClick={() => captureClick('rev')}
          >
            rev
          </a>
        </p>
        <div className='flex flex-row gap-x-4'>
          <a
            target='_blank'
            referrerPolicy='no-referrer'
            href='https://twitter.com/FlowWorkHQ'
            className='font-medium text-metallic-gray hover:underline'
            onClick={() => captureClick('twitter')}
          >
            Twitter
          </a>
        </div>
      </div>
    </div>
  );
}
