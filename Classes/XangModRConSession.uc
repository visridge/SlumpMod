/**
 * One accepted RCON connection.
 *
 * XangModRCon sets AcceptClass to this, so TcpLink hands each incoming connection its own
 * actor. RConState is per-actor, so every client authenticates independently and none of
 * them locks the others out -- all on the single RConPort, which is what a rented server
 * with a fixed port allocation needs.
 *
 * Extends XangModRCon, so auth, HandleMessage and every opcode handler come along
 * unchanged. Handlers call bare SendPacket(), which here is this client's socket.
 */
class XangModRConSession extends XangModRCon;

/**
 * AOCRCon listens from Tick when RConState is RCON_Initialized -- the enum's default. A
 * session already has an accepted socket, so it must not sit in that state even briefly
 * or it would try to BindPort the listener's own port. Accepted() sets Connecting too;
 * this just closes the window before the first Tick.
 */
event PostBeginPlay()
{
	RConState = RCON_Connecting;

	ParentLink = XangModFindListener();

	if (ParentLink != none && ParentLink != self)
		ParentLink.XangModRegisterSession(self);
	else
		LogAlwaysInternal("[XangModRCon] session spawned with no listener to attach to");
}

event Closed()
{
	if (ParentLink != none)
		ParentLink.XangModUnregisterSession(self);

	super.Closed();

	// AOCRCon.Closed drops back to RCON_Initialized whenever LinkState went with it, and Tick
	// binds and listens in that state. For a session that is poison: the actor outlives the
	// socket, so a disconnected client leaves behind a second listener -- on a stray port if
	// RConPort is still held, or ON RConPort after a map change, where it answers connections
	// with no game state and every auth fails. Worse, a failed Listen() calls CloseConnection()
	// which re-enters Closed(), so it retries every frame forever.
	// Nothing here is reusable. Park the state and let the actor go.
	RConState = RCON_Closing;
	LifeSpan = 0.5;
}

event Destroyed()
{
	if (ParentLink != none)
		ParentLink.XangModUnregisterSession(self);

	super.Destroyed();
}

DefaultProperties
{
}
