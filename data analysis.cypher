////////////////////////////////////////////////////////////
// =============  Create Graph Manually  ================ //
////////////////////////////////////////////////////////////

MERGE (a:Faculty{name:"Escuela de Ingenierias Industriales Y Civiles"})
SET a.latitude = 28.070603715538397, a.longitude = -15.455532942038058
MERGE (b:Faculty{name:"Escuela de Arquitectura"})
SET b.latitude = 28.072599659806002, b.longitude = -15.45385214810412
MERGE (c:Faculty{name:"Escuela de Ingeniería Informática"})
SET c.latitude = 28.073224454244844,c.longitude = -15.4515615416922
MERGE (d:Faculty{name:"Edificio Central de la Biblioteca"})
SET d.latitude = 28.071392259790066, d.longitude = -15.453792810601012
MERGE (e:Faculty{name:"Edificio de Ciencias Jurídicas"})
SET e.latitude = 28.07815294577402, e.longitude = -15.449773637745402
MERGE (a)-[:CONNECTION{distance:0.2}]->(b)
MERGE (b)-[:CONNECTION{distance:0.3}]->(c)
MERGE (c)-[:CONNECTION{distance:0.6}]->(d)
MERGE (b)-[:CONNECTION{distance:0.5}]->(d)
MERGE (d)-[:CONNECTION{distance:0.7}]->(e)


////////////////////////////////////////////////////////////
// ===============  Native Projection  ================== //
////////////////////////////////////////////////////////////

CALL gds.graph.create(
    'myGraph',
    'Faculty',
    'CONNECTION',
    {
        nodeProperties: ['latitude', 'longitude'],
        relationshipProperties: 'distance'
    }
)


////////////////////////////////////////////////////////////
// ==============  Run the A* Algorithm  ================ //
////////////////////////////////////////////////////////////

CALL gds.shortestPath.astar.stream('myGraph', {
    sourceNode: source,
    targetNode: target,
    latitudeProperty: 'latitude',
    longitudeProperty: 'longitude',
    relationshipWeightProperty: 'distance'
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN
    index,
    gds.util.asNode(sourceNode).name AS sourceNodeName,
    gds.util.asNode(targetNode).name AS targetNodeName,
    totalCost,
    [nodeId IN nodeIds | gds.util.asNode(nodeId).name] AS nodeNames,
    costs,
    nodes(path) as path
ORDER BY index
