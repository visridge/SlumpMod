// TO maps whose King is a bot instead of the top-scoring defender, read by XangModTO.
// [XangMod.XangModAIKing] Maps=Stoneshill,KingsGarden  (comma-separated, matched inside the map's title or file name)
class XangModAIKing extends Object config(Game);

var config string Maps;
var config bool bDisabled;   // bDisabled=true: Kings stay human everywhere; AdminAIKing overrides per match

DefaultProperties
{
}
