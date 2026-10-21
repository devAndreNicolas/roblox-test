--!strict
export type Phase = "LobbyWaiting" | "LobbyCountdown" | "MatchIntro" | "CallingNumbers" | "SubornAnnouncement" | "RoundComplete"
export type CardCell = { number: number, isFree: boolean, isMarked: boolean }
export type Result = { isDraw: boolean, winnerUserId: number?, winnerName: string? }
export type NoticeKind = "success" | "error" | "info"
export type Notice = { id: number, kind: NoticeKind, text: string }
export type Standing = { userId: number, displayName: string, markedCount: number, remaining: number, rank: number }
export type Snapshot = {
	kind: "Snapshot", sessionId: string, phase: Phase, matchId: number,
	minimumPlayers: number, maximumPlayers: number, waitingPlayers: number, timeRemaining: number,
	callIntervalSeconds: number, phaseDurationSeconds: number,
	isParticipant: boolean, isQueued: boolean, isQueuedForCurrentMatch: boolean, isFirstMatch: boolean,
	card: {CardCell}?, calledNumbers: {number}, lastCalledNumber: number?,
	subornNumber: number?, subornBuyerName: string?, subornsUsed: number, hasUsedSuborn: boolean,
	standings: {Standing}?,
	result: Result?, notice: Notice?,
}
return {}
