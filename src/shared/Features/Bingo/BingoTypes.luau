--!strict
export type Phase = "LobbyWaiting" | "LobbyCountdown" | "MatchIntro" | "CallingNumbers" | "RoundComplete"
export type CardCell = { number: number, isFree: boolean, isMarked: boolean }
export type Result = { isDraw: boolean, winnerUserId: number?, winnerName: string? }
export type NoticeKind = "success" | "error" | "info"
export type Notice = { id: number, kind: NoticeKind, text: string }
export type Snapshot = {
	kind: "Snapshot", sessionId: string, phase: Phase, matchId: number,
	minimumPlayers: number, waitingPlayers: number, timeRemaining: number,
	callIntervalSeconds: number, phaseDurationSeconds: number,
	isParticipant: boolean, isQueued: boolean, isFirstMatch: boolean,
	card: {CardCell}?, calledNumbers: {number}, lastCalledNumber: number?,
	result: Result?, notice: Notice?,
}
return {}
