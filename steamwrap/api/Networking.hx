package steamwrap.api;
import haxe.io.Bytes;
import steamwrap.helpers.SteamBase;
import steamwrap.helpers.Loader;

/**
 * Selective wrapper for Steam networking API.
 * (implementing P2P session API is not required)
 * @author YellowAfterlife
 */
@:allow(steamwrap.api.Steam)
class Networking extends SteamBase {
	
	/**
	 * Sends a packet to the given endpoint.
	 * @param	id	Steam ID of endpoint
	 * @param	bytes	Data to be sent
	 * @param	size	Number of bytes to be sent (usually, bytes.length)
	 * @param	type	Determines method of delivery and reliability
	 * @return	Whether sending succeeded.
	 */
	public function sendPacket(id:SteamID, bytes:Bytes, size:Int, type:EP2PSend):Bool {
		return SteamWrap_SendPacket(id, bytes, size, cast type);
	}
	//private var SteamWrap_SendP2PPacket = Loader.load("SteamWrap_SendP2PPacket", "coiii");
	private var SteamWrap_SendPacket = Loader.loadRaw("SteamWrap_SendPacket", 4);
	
	/**
	 * Pulls the next packet out of receive queue, returns whether there was one.
	 * If successful, also fills out data for getPacketData/getPacketSender.
	 */
	public function receivePacket():Bool {
		return SteamWrap_ReceivePacket();
	}
	private var SteamWrap_ReceivePacket = Loader.loadRaw("SteamWrap_ReceivePacket", 0);
	
	/**
	 * Returns the data of the last received packet as Bytes.
	 * @param	outBytes	If provided, data will be copied into existing Bytes (up to current size)
	 */
	public function getPacketData(?outBytes:Bytes):Bytes {
		if (outBytes != null) {
			SteamWrap_GetPacketData(outBytes);
			return outBytes;
		} else {
			return Bytes.ofData(SteamWrap_GetPacketData(null));
		}
	}
	private var SteamWrap_GetPacketData = Loader.loadRaw("SteamWrap_GetPacketData", 1);
	
	public function getPacketSize():Int {
		return SteamWrap_GetPacketSize();
	}
	private var SteamWrap_GetPacketSize = Loader.loadRaw("SteamWrap_GetPacketSize", 0);
	
	
	/**
	 * Returns Steam ID of sender of the last received packet.
	 */
	public function getPacketSender():SteamID {
		return SteamWrap_GetPacketSender();
	}
	private var SteamWrap_GetPacketSender = Loader.loadRaw("SteamWrap_GetPacketSender", 0);
	
	public var whenP2PSessionRequested:{remoteID:SteamID}->Void = null;
	
	public function acceptP2PSessionWithUser(remote:SteamID):Bool {
		return SteamWrap_AcceptP2PSessionWithUser(remote);
	}
	private var SteamWrap_AcceptP2PSessionWithUser = Loader.loadRaw("SteamWrap_AcceptP2PSessionWithUser", 1);
	
	public function allowP2PPacketRelay(allow:Bool):Bool {
		return SteamWrap_AllowP2PPacketRelay(allow);
	}
	private var SteamWrap_AllowP2PPacketRelay = Loader.loadRaw("SteamWrap_AllowP2PPacketRelay", 1);
	
	public function getP2PSessionState(remoteID:SteamID):P2PSessionState {
		return SteamWrap_GetP2PSessionState(remoteID);
	}
	private var SteamWrap_GetP2PSessionState = Loader.loadRaw("SteamWrap_GetP2PSessionState", 1);
	
	//
	private function new(appId:Int, customTrace:String->Void) {
		if (active) return;
		init(appId, customTrace);
	}
	
}

@:enum abstract EP2PSend(Int) {
	
	/** Akin to UDP */
	public var UNRELIABLE = 0;
	
	/** Akin to UDP with instant send flag */
	public var UNRELIABLE_NO_DELAY = 1;
	
	/** Akin to TCP */
	public var RELIABLE = 2;
	
	/** Akin to TCP with Nagle's algorithm*/
	public var RELIABLE_WITH_BUFFERING = 3;
	
}

typedef P2PSessionState = {
	connected:Bool,
	connecting:Bool,
	lastError:Int,
	usingRelay:Bool,
	bytesQueuedForSend:Int,
	packetsQueuedForSend:Int,
	remoteIP:Int,
	remotePort:Int,
}