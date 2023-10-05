'use client';

import Head from 'next/head'
import { useRef, useState } from 'react';
import clsx from 'clsx';
import posthog from 'posthog-js';

import Airtable from 'airtable';
import { ResponseStatus } from '@/types';

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
  const [ hasSubmitted, setHasSubmitted ] = useState(false);
  const [ error, setError ] = useState(null);

  const [ status, setStatus ] = useState<ResponseStatus>(ResponseStatus.Waiting);
  const [ loading, setLoading ] = useState(false);

  const emailInputRef = useRef<HTMLInputElement>(null);

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
    addEmail(email);
  }

  return (
    <div className="h-screen w-full flex flex-col bg-white">
      <Head>
        <title>Flow Work</title>
        <meta name="description" content={`A social productivity tool designed to help you find your flow.`} />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div id="nav" className="flex flex-row justify-between w-full py-8 px-12">
        {/* this is a placeholder */}
        <div className="h-6"></div>
      </div>
      <div id="main" className="flex flex-col lg:flex-row justify-center items-center w-full h-full gap-12">
        <div id="hero" className='flex flex-col gap-y-5 min-w-[24rem]'>
          <h1 className='text-6xl sm:text-7xl font-bold text-[#001122]'>Flow Work</h1>
          <h2 className='text-[#999999] text-xl font-medium'>Cowork with your team in real time,<br />get sh*t done, and find your flow.</h2>
          <div className="flex flex-row gap-x-3">
            {(status === ResponseStatus.SuccessfullyAdded || status === ResponseStatus.AlreadyExists) ? (
              <span className="text-metallic-gray">
                Download will start shortly. If it doesn't, <a href="https://flowwork.xyz/download" className="text-electric-blue">click here</a>.
              </span>
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
                  Download
                </button>
              </>
            )}
          </div>
        </div>
        <div id="demo" className="w-full sm:w-[40rem] h-auto aspect-auto">
          <video loop autoPlay muted className="object-cover sm:shadow-2xl sm:rounded-lg">
            <source src={'flowwork-demo.mp4'} type="video/mp4" />
          </video>
        </div>
      </div>
      <div id="footer" className="flex flex-row justify-between w-full py-8 px-12">
        <p className="text-metallic-gray font-medium">© 2023 <a href="https://rev.school" target='_blank' referrerPolicy='no-referrer' className="hover:underline">rev</a></p>
        <div className="flex flex-row gap-x-4">
          <a target='_blank' referrerPolicy='no-referrer' href="https://twitter.com/rev_neu" className="text-metallic-gray font-medium hover:underline">Twitter</a>
          <a target='_blank' referrerPolicy='no-referrer' href="https://github.com/teamrevspace/flowwork" className="text-metallic-gray font-medium hover:underline">Github</a>
        </div>
      </div>
    </div>
  )
}

function LeftSide() {
  return <div className="flex-[1/2] m-auto p-8">
    <img width="154" height="27" src="/logo.svg" />
    <h1 className="text-6xl font-bold text-white">
      Flow Work<br />
      <span className="text-[#909aeb]">Waitlist</span>
    </h1>
    <div className="mt-5 text-xl font-light text-white">
      A social productivity tool designed to create a distraction-free co-working space, helping you get into flow state.
    </div>
    <Form />
  </div>
}

function RightSide() {
  return <div className="flex-[1/2] m-auto p-8">
    <img width="100%" height="100%" src="/code.svg" />
  </div>
}

function Form() {
  const [ email, setEmail ] = useState("");
  const [ hasSubmitted, setHasSubmitted ] = useState(false);
  const [ error, setError ] = useState(null);

  const submit = async (e: any) => {
    // We will submit the form ourselves
    e.preventDefault()

    // TODO: make a POST request to our backend
  }

  // If the user successfully submitted their email,
  //   display a thank you message
  if (hasSubmitted) {
    return (<div className="pt-12 flex flex-wrap">
      <span className="text-xl font-light text-white">
        Thanks for signing up! We will be in touch soon.
      </span>
    </div>)
  }

  // Otherwise, display the form
  return
}