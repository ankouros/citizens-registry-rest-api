package gr.university.citizen.service.rest;

import gr.university.citizen.domain.Citizen;
import gr.university.citizen.service.core.CitizenService;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.List;

/**
 * REST resource for managing citizens.
 * The methods here are intentionally minimal and should be completed
 * according to the assignment's functional requirements.
 */
@Path("/citizens")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CitizenResource {

    @Inject
    private CitizenService citizenService;

    @GET
    public List<Citizen> getAll() {
        return citizenService.findAll();
    }

    @GET
    @Path("/{id}")
    public Citizen getById(@PathParam("id") Long id) {
        try {
            return citizenService.findById(id);
        } catch (IllegalArgumentException ex) {
            throw new NotFoundException(ex.getMessage(), ex);
        }
    }

    @POST
    public Response create(Citizen citizen) {
        try {
            Citizen created = citizenService.create(citizen);
            return Response.status(Response.Status.CREATED).entity(created).build();
        } catch (IllegalArgumentException ex) {
            throw new BadRequestException(ex.getMessage(), ex);
        }
    }

    @PUT
    @Path("/{id}")
    public Response update(@PathParam("id") Long id, Citizen citizen) {
        try {
            Citizen updated = citizenService.update(id, citizen);
            return Response.ok(updated).build();
        } catch (IllegalArgumentException ex) {
            throw mapToWebException(ex);
        }
    }

    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") Long id) {
        try {
            citizenService.delete(id);
            return Response.noContent().build();
        } catch (IllegalArgumentException ex) {
            throw mapToWebException(ex);
        }
    }

    private RuntimeException mapToWebException(IllegalArgumentException ex) {
        String message = ex.getMessage();
        if (message != null && message.toLowerCase().contains("not found")) {
            return new NotFoundException(message, ex);
        }
        return new BadRequestException(message, ex);
    }
}
