export default function LoginPage() {
  return (
    <main className="mx-auto max-w-md px-6 py-16">
      <h1 className="text-2xl font-semibold mb-4">Connexion</h1>
      <form className="space-y-4">
        <input type="email" placeholder="Email" className="w-full border px-3 py-2 rounded" />
        <input type="password" placeholder="Mot de passe" className="w-full border px-3 py-2 rounded" />
        <button className="w-full bg-black text-white py-2 rounded">Se connecter</button>
      </form>
      <p className="mt-4 text-sm">Pas de compte ? <a className="underline" href="/auth/register">Inscrivez-vous</a></p>
    </main>
  )
}

