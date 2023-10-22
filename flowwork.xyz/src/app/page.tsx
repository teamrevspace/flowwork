'use client';

import Head from 'next/head'
import { useRef, useState } from 'react';
import clsx from 'clsx';
import posthog from 'posthog-js';
import Image from 'next/image';

import Airtable from 'airtable';
import { ResponseStatus } from '@/types';
import Link from 'next/link';
import { redirect, useRouter } from 'next/navigation';

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
  const [ email, setEmail ] = useState("");

  const [ status, setStatus ] = useState<ResponseStatus>(ResponseStatus.Waiting);
  const [ loading, setLoading ] = useState(false);

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
        setLoading(false);
      }
    } else {
      emailInputRef.current?.focus();
    }
  };

  const signup = async (e: any) => {
    e.preventDefault()
    addEmail(email)
  }

  const downloadApp = () => {
    captureClick('download');
    router.push('/download');
  }

  return (
    <div className="h-full min-h-screen lg:h-screen w-full flex flex-col bg-white">
      <Head>
        <title>Flow Work</title>
        <meta name="description" content={`A social productivity tool designed to help you find your flow.`} />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div id="nav" className="flex flex-row justify-between w-full py-8 px-12">
      </div>
      <div id="main" className="flex flex-col lg:flex-row justify-center items-center w-full h-full gap-12 mx-auto sm:px-8">
        <div id="hero" className='flex flex-col gap-y-5 sm:min-w-[24rem] px-6 sm:px-0'>
          <img className="h-24 w-24 sm:h-32 sm:w-32" src="/logo.png" />
          <h1 className='text-6xl sm:text-7xl font-bold text-[#001122]'>Flow Work</h1>
          <h2 className='text-[#999999] text-xl font-medium'>Cowork with friends in real time,<br />find your flow, and get sh*t done.</h2>
          <div className="flex flex-row gap-x-3">
            {(status === ResponseStatus.SuccessfullyAdded || status === ResponseStatus.AlreadyExists) ? (
              <p className="flex items-center justify-center text-[#3a3a3a] h-[52px]">
                Download will start shortly. If it doesn&apos;t,&nbsp;<button onClick={(e) => {
                  e.preventDefault()
                  downloadApp()
                }} className="text-electric-blue">{`click here`}</button>.
              </p>
            ) : (
              <>
                <input ref={emailInputRef}
                  name="email_address"
                  onChange={(e) => {
                    validateEmail(e.target.value)
                    setEmail(e.target.value)
                  }
                  }
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      signup(e);
                    }
                  }}
                  type="email"
                  value={email}
                  required={true}
                  autoComplete='off'
                  aria-label="Email address"
                  className={clsx(
                    'appearance-none shadow rounded-xl ring-1 ring-silver leading-5 border border-transparent px-6 py-3 placeholder:text-black placeholder:text-opacity-25 block max-w-[360px] w-full text-[#222222] focus:outline-none focus:ring-2 bg-[#f2f2f2]',
                    (status === ResponseStatus.AddFailed || status === ResponseStatus.InvalidFormat) &&
                    'focus:ring-red-500',
                    (status === ResponseStatus.Waiting || status === ResponseStatus.Ready) && 'focus:ring-electric-blue'
                  )}
                  placeholder="name@email.com" />
                <button onClick={(e) => signup(e)} type="button" className="px-5 py-3 border-none rounded-xl text-lg font-medium w-2/5 bg-electric-blue hover:bg-electric-blue-accent text-white">
                  {loading ? (
                    <div className="flex justify-center items-center w-full h-7">
                      <Image className="animate-spin" width={24} height={24} src="spinner.svg" alt={'Loading...'} />
                    </div>
                  ) : 'Download'
                  }
                </button>
              </>
            )}
          </div>
        </div>
        <div id="demo" className="w-full sm:w-[40rem] h-auto aspect-auto">
          <video loop autoPlay muted playsInline onContextMenu={() => false} preload="auto" className="object-cover w-full h-full sm:shadow-2xl sm:rounded-lg bg-black">
            <source src={'flowwork-demo.mp4'} type="video/mp4" />
          </video>
        </div>
      </div>
      <div id="footer" className="flex flex-row justify-between w-full py-8 px-12 flex-grow items-end">
        <p className="text-metallic-gray font-medium">© 2023 <a href="https://rev.school" target='_blank' referrerPolicy='no-referrer' className="hover:underline">rev</a></p>
        <div className="flex flex-row gap-x-4">
          <a target='_blank' referrerPolicy='no-referrer' href="https://twitter.com/rev_neu" className="text-metallic-gray font-medium hover:underline">Twitter</a>
          <a target='_blank' referrerPolicy='no-referrer' href="https://github.com/teamrevspace/flowwork" className="text-metallic-gray font-medium hover:underline">Github</a>
        </div>
      </div>
    </div>
  )
}
