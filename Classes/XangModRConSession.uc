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
