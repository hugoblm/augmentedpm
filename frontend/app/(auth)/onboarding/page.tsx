"use client"
import { useState } from 'react'
import { OnboardingForm } from '@/lib/types'
import { generateRecommendations } from '@/lib/api'

export default function OnboardingPage() {
  const [answers, setAnswers] = useState<OnboardingForm>({
    experience: 'beginner', interests: [], goals: [], company_size: '1-10'
  })
  const [recs, setRecs] = useState([] as {id: string; title: string}[])

  return (
    <main className="mx-auto max-w-2xl px-6 py-10">
      <h1 className="text-2xl font-semibold mb-4">Onboarding</h1>
      <div className="space-y-4">
        <label className="block">
          Niveau d'expérience
          <select className="w-full border px-2 py-2 rounded" value={answers.experience}
            onChange={e => setAnswers(a => ({...a, experience: e.target.value as any}))}>
            <option value="beginner">Débutant</option>
            <option value="intermediate">Intermédiaire</option>
            <option value="expert">Expert</option>
          </select>
        </label>
        <button className="bg-black text-white px-4 py-2 rounded" onClick={() => setRecs(generateRecommendations(answers))}>Générer recommandations</button>
        <ul className="list-disc pl-6">
          {recs.map(r => (<li key={r.id}>{r.title}</li>))}
        </ul>
      </div>
    </main>
  )
}

