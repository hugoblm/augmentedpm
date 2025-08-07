interface Props { params: { id: string, moduleId: string } }
export default function ModuleDetail({ params }: Props) {
  return (
    <main className="mx-auto max-w-3xl px-6 py-10">
      <h1 className="text-2xl font-semibold mb-4">Formation {params.id} — Module {params.moduleId}</h1>
      <p>Contenu du module.</p>
    </main>
  )
}

