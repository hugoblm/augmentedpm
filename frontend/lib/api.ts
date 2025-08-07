import { OnboardingForm, Formation } from '@/lib/types'

export function generateRecommendations(answers: OnboardingForm): Formation[] {
  const catalog: Formation[] = [
    { id: 'pm-ai-fundamentals', title: 'Fundamentaux PM IA', level: 'beginner' },
    { id: 'pm-ai-roadmaps', title: 'Roadmaps IA', level: 'intermediate' },
    { id: 'pm-ai-analytics', title: 'Analytics et IA', level: 'expert' },
  ]
  return catalog.filter(c => {
    if (answers.experience === 'beginner') return c.level === 'beginner'
    if (answers.experience === 'intermediate') return c.level !== 'beginner'
    return c.level === 'expert'
  })
}

