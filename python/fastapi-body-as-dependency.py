async def use_tracer_dependency(
    request: Request,
    context: ContextPayload = Depends(get_context),
):
    body_bytes = await request.body()
    if body_bytes:
        body = await request.json()
    else:
        raise ValueError("empty body is not allowed.")
    graph_id = body.get("graph_id", "")
    project_name = f"graph-{context.project.id}_{body.graph_id}"
    with using_tracer(
        project_name=project_name,
        session_id=str(uuid.uuid4()),
        user_id=context.user.username,
        metadata={},
        tags=None,
    ) as tracer:
        yield tracer
