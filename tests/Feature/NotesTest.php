<?php

declare(strict_types=1);

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class NotesTest extends TestCase
{
    use RefreshDatabase;

    public function test_the_notes_page_loads(): void
    {
        $this->get('/')->assertOk()->assertSee('No notes yet.');
    }

    public function test_a_saved_note_appears_on_the_page(): void
    {
        $body = '<em>A sample note</em>';

        $this->post('/notes', ['body' => $body])->assertRedirect('/');
        $this->assertDatabaseHas('notes', ['body' => $body]);
        $this->get('/')->assertOk()->assertSee($body);
    }

    public function test_an_invalid_note_is_rejected(): void
    {
        $this->from('/')->post('/notes', ['body' => str_repeat('a', 241)])
            ->assertRedirect('/')
            ->assertSessionHasErrors('body');

        $this->assertDatabaseCount('notes', 0);
    }
}
