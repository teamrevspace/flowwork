import Link from "next/link";

export default function Download() {
  return (
    <div className="h-full lg:h-screen w-full flex flex-col bg-white">
      <div className="flex flex-col items-center justify-center flex-1 gap-y-4">
        <Link href="/">
        <img className="h-24 w-24 sm:h-32 sm:w-32" src="/logo.png" />
        </Link>
        <h1 className="text-3xl font-bold text-[#001122]">Flow Work is currently in development 🚀</h1>
        <p className="text-xl text-[#999999]">We&apos;ll send you an email when it&apos;s ready 👀</p>
      </div>
    </div>
  )
}