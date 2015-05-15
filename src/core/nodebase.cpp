#include "nodebase.h"

/*!
 * \class NodeBase
 * \brief The NodeBase class provides the basic functionality of all nodes.
 *
 * All nodes in Neuronify inherit from NodeBase.
 * It holds a pointer to a NodeEngine and a list of all connected edges.
 * Only the connected Edge object is allowed to add or remove edges of a
 * NodeBase object.
 *
 * The only reason for the existence of NodeBase is that NodeEngine and
 * GraphEngine cannot know about the \l Node type, because \l Node is
 * defined in QML.
 *
 * \sa Node, NodeBase
 *
 */

NodeBase::NodeBase(QQuickItem *parent)
    : QQuickItem(parent)
{

}

NodeBase::~NodeBase()
{

}

NodeEngine *NodeBase::engine() const
{
    return m_engine;
}

void NodeBase::setEngine(NodeEngine *arg)
{
    if (m_engine == arg)
        return;

    m_engine = arg;
    emit engineChanged(arg);
}

void NodeBase::addEdge(Edge *edge)
{
    emit edgeAdded(edge);
}

void NodeBase::removeEdge(Edge *edge)
{
    emit edgeRemoved(edge);
}