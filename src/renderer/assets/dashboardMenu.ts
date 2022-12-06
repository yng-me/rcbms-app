

interface SidebarMenu {
    id: number
    label: string,
    icon: string
    isActive: boolean
}

export const iconSize = 20

export const sidebarMenu : SidebarMenu[] = [
    {
        id: 1,
        label: 'Dashboard',
        icon: `<svg width="${iconSize}" height="${iconSize}" viewBox="0 0 48 48"><g fill="none" stroke="currentColor" stroke-linejoin="round" stroke-width="4"><path stroke-linecap="round" d="M4 30L9 6h30l5 24"/><path d="M4 30h10.91l1.817 6h14.546l1.818-6H44v13H4V30Z"/><path stroke-linecap="round" d="M19 14h10m-13 8h16"/></g></svg>`,
        isActive: true
    },
    {
        id: 2,
        label: 'Tables',
        icon: `<svg width="${iconSize}" height="${iconSize}" viewBox="0 0 48 48"><g fill="none" stroke="currentColor" stroke-linejoin="round" stroke-width="4"><path d="M42 6H6a2 2 0 0 0-2 2v32a2 2 0 0 0 2 2h36a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2Z"/><path stroke-linecap="round" d="M4 18h40m-26.5 0v24m13-24v24M4 30h40m0-22v32a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V8"/></g></svg>`,
        isActive: false
    },
    {
        id: 3,
        label: 'Settings',
        icon: `<svg width="${iconSize}" height="${iconSize}" viewBox="0 0 48 48"><g fill="none" stroke="currentColor" stroke-linejoin="round" stroke-width="4"><path d="M18.284 43.171a19.995 19.995 0 0 1-8.696-5.304a6 6 0 0 0-5.182-9.838A20.09 20.09 0 0 1 4 24c0-2.09.32-4.106.916-6H5a6 6 0 0 0 5.385-8.65a19.968 19.968 0 0 1 8.267-4.627A6 6 0 0 0 24 8a6 6 0 0 0 5.348-3.277a19.968 19.968 0 0 1 8.267 4.627A6 6 0 0 0 43.084 18A19.99 19.99 0 0 1 44 24c0 1.38-.14 2.728-.406 4.03a6 6 0 0 0-5.182 9.838a19.995 19.995 0 0 1-8.696 5.303a6.003 6.003 0 0 0-11.432 0Z"/><path d="M24 31a7 7 0 1 0 0-14a7 7 0 0 0 0 14Z"/></g></svg>`,
        isActive: false
    }
]