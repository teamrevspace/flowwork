"use client"

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useCallback, useEffect } from "react";

export default function JoinSessionPage({ params }: { params: { id: string } }) {
  const router = useRouter();

  const downloadApp = async () => {
    router.push('/download');
  }

  const joinSession = useCallback(async () => {
    router.replace(`flowwork://join?sessionId=${params.id}`)
  }, [params.id, router])

  useEffect(() => {
    joinSession()
  }, [params.id, joinSession])

  return (
    <div className="h-screen w-full flex flex-col bg-white px-6">
      <div className="flex flex-col items-center justify-center flex-1 gap-y-4">
        <Link href="/">
          <img className="h-24 w-24 sm:h-32 sm:w-32" src="/logo.png" />
        </Link>
        <h1 className="text-2xl sm:text-4xl font-bold text-center text-[#001122]">Launching Flow Work 🚀</h1>
        <p className="text-base sm:text-lg text-center text-[#999999]">If you don&apos;t have Flow Work installed,&nbsp;<button onClick={(e) => {
          e.preventDefault()
          downloadApp()
        }} className="text-electric-blue">{`click here`}</button></p>
        <button onClick={(e) => {
          e.preventDefault()
          joinSession()
        }} type="button" className="px-8 sm:px-12 py-2 sm:py-3 border-none rounded-xl text-base sm:text-lg font-medium bg-electric-blue hover:bg-electric-blue-accent text-white">
          Join session
        </button>
        <p className="text-sm sm:text-base text-[#999999] text-center">or copy-paste the session code:&nbsp;<code className="bg-silver">{params.id}</code></p>
      </div>
    </div>
  )
}